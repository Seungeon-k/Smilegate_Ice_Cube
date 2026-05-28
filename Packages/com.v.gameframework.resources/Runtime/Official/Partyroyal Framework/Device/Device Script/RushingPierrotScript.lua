local this = __CREATOR__.new()

this.IsSpawnOnStart = __EX_VARIABLE__.bool()
this.AutoPlay = __EX_VARIABLE__.bool()
this.Repeat = __EX_VARIABLE__.bool()
this.ActiveBoundary = __EX_VARIABLE__.vobject()
this.DelayBeforeIndicator = __EX_VARIABLE__.float(1)
this.DelayBeforeRush = __EX_VARIABLE__.float(1)
this.RushSpeed = __EX_VARIABLE__.float(10)
this.FinalAcceleration = __EX_VARIABLE__.float(20.0)
this.PierrotSturnDuration = __EX_VARIABLE__.float(2.0)

this.OnAttackSequenceCompleted = __EX_VARIABLE__.event()
this.OnCollisionCharacter = __EX_VARIABLE__.event(__EX_VARIABLE__.vobject())

this.rootObject = __EX_VARIABLE__.vobject()
this.walrusObject = __EX_VARIABLE__.vobject()
this.rigidbody = _VCOMPONENT_.rigidbody()
this.animator = _VCOMPONENT_.animator()
this.vfxIndicator = __EX_VARIABLE__.vobject()
this.vfxMove = _VCOMPONENT_.particleSystem()
this.vfxStun = _VCOMPONENT_.particleSystem()

this.soundListStart = __EX_VARIABLE__.list(_VASSET_.audioClip())
this.soundListTrail = __EX_VARIABLE__.list(_VASSET_.audioClip())
this.soundListLoop = __EX_VARIABLE__.list(_VASSET_.audioClip())
this.soundListEnd = __EX_VARIABLE__.list(_VASSET_.audioClip())

this.spawnStarted = __EX_VARIABLE__.bool(false)
this.startAttackSequence = __EX_VARIABLE__.bool(false)
this.attackSequenceCount = __EX_VARIABLE__.int()
this.maxSpeed = __EX_VARIABLE__.float(100.0)
this.knockbackScript = _VOBJECT_.script():lua()
this.visibleScript = _VOBJECT_.script():lua()


local serviceApi
local scriptObject
local soundService
local playerService
local physicsService

local targetPlayer
local targetLockOn = false
local canRush = false
local asyncHandle
local vfxIndicatorPosition
local vfxIndicatorPropBinder

local lockOnAngle = 2
local turnSpeedDegPerSec = 360.0
local velocity

local activeBoundaryCollider
local isStunned = false

local _APPEAR_RATIO = '_MorphMax'

local function IsInTargetState(animator, stateName, includeInTransition)  
  if animator == nil or stateName == nil or stateName == '' then
    return
  end

  includeInTransition = includeInTransition or false

  local baseLayer = 0
  if includeInTransition and animator:IsInTransition(baseLayer) then
    local next = animator:GetNextAnimatorStateInfo(baseLayer)
    if next:IsName(stateName) then
        return true
    end
  else
    local stateInfo = animator:GetCurrentAnimatorStateInfo(baseLayer)
    if stateInfo:IsName(stateName) then
      return true
    end
  end
end


local function playRandomSound(soundList)
    local playIndex = math.random(1, #soundList)
    if soundService then
        soundService:Play(soundList[playIndex])
    end
end

local eps = 1e-4
local function isInside(area, p)
    local cp = area:ClosestPoint(p)
    local v = cp - p
    return v.sqrMagnitude <= eps * eps
end


local function calcTargetPlayer()
    local players = playerService:GetPlayers()
    if players == nil then return nil end

    local activePlayers = {}
    for _, player in ipairs(players) do
        local character = player.character
        if character and not character.isKnockedDown and not character.isFalling then
            if activeBoundaryCollider then
                local inside = isInside(activeBoundaryCollider, character.transform.position)
                if inside then
                    table.insert(activePlayers, player)
                end
            end
        end
    end

    if #activePlayers > 0 then
        local targetIndex = math.random(1, #activePlayers)
        return activePlayers[targetIndex]
    end

    return nil
end

local function findBoundaryHitPoint(hits)
    for i, hit in ipairs(hits) do
        if hit.collider == activeBoundaryCollider then
            return true, hit.point
        end
    end

    return false, Vector3.zero
end

local maxDistance = 1000
local function activateRush()
    VFramework.WaitForSeconds(this.DelayBeforeIndicator)

    playRandomSound(this.soundListTrail)
    this.vfxIndicator:SetParent(this.ActiveBoundary)
    this.vfxIndicator.transform:SyncTransform()


    VFramework.WaitForSeconds(0.1) -- rb.rotation 동기화 이슈 대응용 0.1 대기 추가

    -- shader 내용 수정 후 반영해야함    
    local forward = this.vfxIndicator.transform.forward
    local direction = -forward
    local location = this.vfxIndicator.transform.position + forward * maxDistance
    local ray = Ray.New(direction, location)
    local hits = physicsService:RaycastAll(ray, maxDistance)

    local found, point = findBoundaryHitPoint(hits)
    if found then
        local distance = Vector3.Distance(this.vfxIndicator.transform.position, point)
        
        local t = Mathf.InverseLerp(0, 95, distance)
        local v = Mathf.Lerp(0.3, 1, t)

        --print('activate rush: ', distance, t, v)
        vfxIndicatorPropBinder:SetFloat(_APPEAR_RATIO, v)
    end
    

    this.vfxIndicator:SetActive(true)

    VFramework.WaitForSeconds(this.DelayBeforeRush)

    playRandomSound(this.soundListStart)
    this.animator:SetBool('IsSeal_Move', true)

    
    canRush = true
end

local function deactivateRush()
    canRush = false
    this.animator:SetBool('IsSeal_Move', false)

    velocity = Vector3.zero
    playRandomSound(this.soundListEnd)
end

local function lookAtTargetPlayer(character, fixedDeltaTime)
    if targetLockOn then return end

    local toTarget  = character.transform.position - this.rigidbody.position
    toTarget.y = 0

    if  toTarget.sqrMagnitude < Mathf.Epsilon then return end

    local desiredDir = toTarget.normalized
    local forward = this.walrusObject.transform.forward

    local dot = Vector3.Dot(forward, desiredDir);
    
    local cosThreshold = Mathf.Cos(lockOnAngle * Mathf.Deg2Rad);
    --local angle = Vector3.Angle(forward, desiredDir)

    if dot > Mathf.Epsilon and dot >= cosThreshold then -- 정면인데 적당한 방향이다?
        targetLockOn = true
        return
    end

    local desiredRot = Quaternion.LookRotation(desiredDir, Vector3.up)
    local maxStep = turnSpeedDegPerSec * fixedDeltaTime
    local next = Quaternion.RotateTowards(this.rigidbody.rotation, desiredRot, maxStep)

    this.rigidbody:MoveRotation(next)

end

local function moveToTargetPlayer(fixedDeltaTime)
    if canRush then

        local direction = this.walrusObject.transform.forward      
        local targetVel = direction * this.maxSpeed

        velocity = Vector3.MoveTowards(velocity, targetVel, this.FinalAcceleration * fixedDeltaTime)

        this.rigidbody:MovePosition(this.rigidbody.position + (velocity * fixedDeltaTime))

        --print("dt", fixedDeltaTime, "RushSpeed", this.RushSpeed, "vel", velocity:Magnitude(), "canRush", canRush)
    end
end

local currentStateName = 'Spawn' -- 연출 시작전까지는 Spawn State
local function nowSpawnState() return currentStateName == 'Spawn' end
local function nowHoldingState() return currentStateName == 'Holding' end
local function nowPenetrateState() return currentStateName == 'Penetrate' end
local function nowStunState() return currentStateName == 'Stun' end

local function stopMove()
    if canRush and nowPenetrateState() then
        print('arrived active boundary')
        deactivateRush()
    end
end

local function finishStun()
    VFramework.WaitForSeconds(this.PierrotSturnDuration)

    this.vfxStun:Stop()
    this.animator:SetBool('IsSeal_Stun', false)

    isStunned = false
end

local function startStun()
    print('start Stun')
    isStunned = true

    stopMove()
    this.animator:SetBool('IsSeal_Stun', true)
    this.vfxStun:Play()

    scriptObject:AsyncCall(finishStun)
end

local function deactivateIndicator()
    if this.vfxIndicator.activeSelf then

        this.vfxIndicator:SetActive(false)
        this.vfxIndicator:SetParent(this.walrusObject)
        this.vfxIndicator.transform.localPosition = vfxIndicatorPosition
        this.vfxIndicator.transform:SyncTransform()

        this.OnAttackSequenceCompleted:Call()
        this.vfxMove:Stop()
    end
end

local crashedCharacters = {}
local function controlCrashedCharacter()
    print('controlCrashedCharacter')
    for character, onCrashed in pairs(crashedCharacters) do
        if character ~= nil and onCrashed then
            if character:HasBuff('Buff.Statue') then
                if not isStunned then
                    startStun()
                end
            else
                if not character.isKnockedDown and not character.isFalling then
                    this.OnCollisionCharacter:Call(character)
                end
            end
        end
    end
end

local animStateHandlers = {
    Spawn = {
        start = function()
            print('WalrusState : start Spawn')
        end,
        update = function(dt)
        end,
        fixedUpdate = function(dt)
        end,
    },
    Holding = {
        start = function()
            print('WalrusState : start Holding')

            canRush = false
            asyncHandle = nil

            if this.spawnStarted then
                if this.attackSequenceCount <= 0 then
                    this.startAttackSequence = this.AutoPlay
                else
                    this.startAttackSequence = this.Repeat
                end
            end
            deactivateIndicator()

            controlCrashedCharacter()
            
        end,
        update = function(dt)

            if this.startAttackSequence and this.spawnStarted then
                if targetPlayer == nil then -- 외부에서 입력받을 가능성으로 update에서 확인
                    targetPlayer = calcTargetPlayer()
                end

                if targetLockOn and asyncHandle == nil then
                    asyncHandle = scriptObject:AsyncCall(activateRush)
                end
            end
        end,
        fixedUpdate = function(dt)
            if targetPlayer and targetPlayer.character then
                lookAtTargetPlayer(targetPlayer.character, dt)
            end
        end,
    },
    Penetrate = {
        start = function()
            print('WalrusState : start Penetrate')
            
            asyncHandle = nil
            targetPlayer = nil
            targetLockOn = false

            this.attackSequenceCount = this.attackSequenceCount + 1

            velocity = this.walrusObject.transform.forward * this.RushSpeed
            this.vfxMove:Play()
            playRandomSound(this.soundListLoop)
            
        end,
        update = function(dt)
            if canRush then
                controlCrashedCharacter()
            end
        end,
        fixedUpdate = function(dt)
            if canRush then
                moveToTargetPlayer(dt)
            end
        end,
    },
    Stun = {
        start = function()
            print('WalrusState : start Stun')
            
        end,
        update = function(dt)
        end,
        fixedUpdate = function(dt)
        end,
    }
    
}

local function resetAniamtor()
    this.animator:SetBool('IsSeal_Spawn_1', false)
    this.animator:SetBool('IsSeal_Spawn_2', false)
    this.animator:SetBool('IsSeal_Move', false)
    this.animator:SetBool('IsSeal_Stun', false)
    this.animator:Play('Spawn', 0, 0)
end

-- 원주(둘레) 위에서 균일 랜덤 점 뽑기
-- r: 반지름, cx/cy: 중심(기본 0,0)
-- 반환: x, y, theta(라디안)
local function randomPointOnCircle(r, cx, cy)
  cx = cx or 0
  cy = cy or 0

  local theta = math.random() * 2.0 * math.pi
  local x = cx + r * math.cos(theta)
  local y = cy + r * math.sin(theta)
  return x, y, theta
end

local function resetWalrusLocation()
    _, activeBoundaryCollider = this.ActiveBoundary:GetComponentByType(typeof(VFramework.Collider))
    local x, z, _ = randomPointOnCircle(activeBoundaryCollider.radius)
    this.walrusObject.transform.position = Vector3.New(x, this.walrusObject.transform.position.y, z)
end

local function startSpawn()
    this.rootObject:SetActive(true)

    local value = math.random(0, 1) == 1
    if value then
        this.animator:SetBool('IsSeal_Spawn_1', true)
    else
        this.animator:SetBool('IsSeal_Spawn_2', true)
    end
    this.spawnStarted = true
end

local function onHideComplete()
    this.rootObject:SetActive(false)
end

local function onShowComplete()
    startSpawn()
end

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject

    soundService = serviceApi.soundService
    playerService = serviceApi.playerService
    physicsService = serviceApi.physicsService

    vfxIndicatorPosition = this.vfxIndicator.transform.localPosition
    velocity = Vector3.zero    

    resetWalrusLocation()

    this.visibleScript.IsVisibleOnStart = this.IsSpawnOnStart
    this.walrusObject:SetActive(this.IsSpawnOnStart)

    local ok, binder = this.vfxIndicator:GetComponentInChildrenByType(typeof(VFramework.MaterialPropertyBinder))
    if ok then
        vfxIndicatorPropBinder = binder
        vfxIndicatorPropBinder:SetFloat(_APPEAR_RATIO, 1.0)
    end
end

function this.OnStart()
    this.knockbackScript.ChangeDisableInternalMode()

    this.visibleScript.OnShowComplete:AddListener(onShowComplete)
    this.visibleScript.OnHideComplete:AddListener(onHideComplete)

    this.vfxMove:Stop()
    this.vfxStun:Stop()
end

local function findHandler(animHandlers)
    for stateName, handler in pairs(animHandlers) do
        if IsInTargetState(this.animator, stateName) then
            if currentStateName ~= stateName then
                handler.start()
                currentStateName = stateName
            end
            
            return handler
        end
    end
    return nil
end

function this.OnUpdate(deltaTime)
    local handler = findHandler(animStateHandlers)
    if handler ~= nil then
        handler.update(deltaTime)
    end
end

function this.OnFixedUpdate(fixedDeltaTime)
    local handler = findHandler(animStateHandlers)
    if handler ~= nil then
        handler.fixedUpdate(fixedDeltaTime)
    end
end


local function checkCharacter(vObject)
    return vObject:CastByType(typeof(VFramework.Character))
end

local function checkItem(vObject)
    return vObject:CastByType(typeof(VFramework.Item))
end



function this.OnCollisionEnter(collision)
    local charYes, character = checkCharacter(collision.vObject)
    if charYes then
        print('collision enter character')
        crashedCharacters[character] = true

        controlCrashedCharacter()
    end

    local itemYes, item = checkItem(collision.vObject)
    if itemYes then
        print('collision item')

        if item.itemID == 'Item.Bat' or item.itemID == 'Item.Bomb' then
            startStun()
        end
    end
end

function this.OnCollisionExit(collision)
    local ok, character = checkCharacter(collision.vObject)
    if ok then
        print('collision exit character')
        controlCrashedCharacter()
        crashedCharacters[character] = false
    end
    
end


function this.OnBoundaryExit()
    stopMove()
end


-- __EX_FUNCTION__(this)
-- function this.OnShowAutoStart()
--     if scriptObject.activeSelf and this.AutoPlay then
--             this.startAttackSequence = true
--     end
-- end

__EX_FUNCTION__(this)
function this.Spawn()
    resetWalrusLocation()
    this.walrusObject:SetActive(true)
    resetAniamtor()
    this.visibleScript.Show()
end

__EX_FUNCTION__(this)
function this.Despawn()
    if this.spawnStarted then
        this.spawnStarted = false
        this.startAttackSequence = false

        if asyncHandle then
            asyncHandle:Stop()
            asyncHandle = nil
        end

        targetPlayer = nil
        targetLockOn = false

        stopMove()
        deactivateIndicator()

        this.visibleScript.Hide()
    end
end

__EX_FUNCTION__(this)
function this.StartAttack()
    this.startAttackSequence = true
end

__EX_FUNCTION__(this)
function this.FinishAttack()
    this.startAttackSequence = false
    stopMove()
end

