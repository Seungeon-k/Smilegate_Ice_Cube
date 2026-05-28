local this = __CREATOR__.new()

this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
this.DashAttackToIceCrack1 = __EX_VARIABLE__.int(1)
this.DashAttackToIceCrack2 = __EX_VARIABLE__.int(4)
this.DashAttackToIceBreak = __EX_VARIABLE__.int(3)

this.CanRespawn = __EX_VARIABLE__.bool(true)
this.RespawnDelay = __EX_VARIABLE__.float(5)


this.isBroken = __EX_VARIABLE__.bool(false)

this.iceWallLevel1 = __EX_VARIABLE__.vobject()
this.iceWallLevel2 = __EX_VARIABLE__.vobject()
this.iceWallLevel3 = __EX_VARIABLE__.vobject()

this.rootCollider = _VCOMPONENT_.collider()
this.animator = _VCOMPONENT_.animator()
this.vfxIceBroken = _VCOMPONENT_.particleSystem()

this.soundDoorCrackLevel1 = __EX_VARIABLE__.list(_VASSET_.audioClip())
this.soundDoorCrackLevel2 = __EX_VARIABLE__.list(_VASSET_.audioClip())
this.soundDoorBreak = __EX_VARIABLE__.list(_VASSET_.audioClip())

this.visibleScript = _VOBJECT_.script():lua()

local serviceApi
local soundService
local scriptObject

local currentWall
local iceWallLife = 0

local wallVelocity
local updatedLocalPosition
local hasSecondStepMove = true
local shownBroken = false

local enteredCharacter = {}
local dashedCharacter = {}

local function playRandomSound(soundList)
    if soundList == nil then return end
    local playIndex = math.random(1, #soundList)
    if soundService then
        soundService:Play(soundList[playIndex])
    end
end


local prevOpenedLevel1 = false
local prevOpenedLevel2 = false
local prevOpenedLevel3 = false

local function updateIceWallActive()
    
    local openLevel1 = iceWallLife > this.DashAttackToIceCrack2 + this.DashAttackToIceBreak
    local openLevel2 = not openLevel1 and iceWallLife > this.DashAttackToIceBreak
    local openLevel3 = not openLevel1 and not openLevel2

    this.iceWallLevel1:SetActive(openLevel1)
    this.iceWallLevel2:SetActive(openLevel2)
    this.iceWallLevel3:SetActive(openLevel3)

    if openLevel1 then
        currentWall = this.iceWallLevel1
    end

    if openLevel2 then
        currentWall = this.iceWallLevel2
    end

    if openLevel3 then
        currentWall = this.iceWallLevel3
        this.animator.enabled = true
    end

    if not prevOpenedLevel2 and openLevel2 then
        playRandomSound(this.soundDoorCrackLevel1)
    end

    if not prevOpenedLevel3 and openLevel3 then
        playRandomSound(this.soundDoorCrackLevel2)
    end

    prevOpenedLevel1 = openLevel1
    prevOpenedLevel2 = openLevel2
    prevOpenedLevel3 = openLevel3
    
end

local function reset()
    iceWallLife = (this.DashAttackToIceCrack1 + this.DashAttackToIceCrack2 + this.DashAttackToIceBreak)

    this.iceWallLevel1.transform.localPosition = Vector3.zero
    this.iceWallLevel2.transform.localPosition = Vector3.zero
    this.iceWallLevel3.transform.localPosition = Vector3.zero

    shownBroken = false    
    this.animator:SetBool('IsBroken', false)
    this.animator:Play('StandBy', 0, 0)
    this.animator.enabled = false
    this.rootCollider.enabled = true

    this.isBroken = iceWallLife <= 0
    
    enteredCharacter = {}
    dashedCharacter = {}

    wallVelocity = Vector3.zero
    updatedLocalPosition = Vector3.zero
    hasSecondStepMove = true

    updateIceWallActive()
end

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject

    soundService = serviceApi.soundService

    this.DashAttackToIceCrack1 = math.max(0, this.DashAttackToIceCrack1)
    this.DashAttackToIceCrack2 = math.max(0, this.DashAttackToIceCrack2)
    this.DashAttackToIceBreak = math.max(0, this.DashAttackToIceBreak)
    
    this.visibleScript.IsVisibleOnStart = this.IsVisibleOnStart
end

local punchDistance = 2.5 -- 순간 밀림 거리(미터)
local maxOffset = 0.15     -- 과도한 누적 방지
local returnTime = 0.02    -- 0으로 돌아오는 시간(작을수록 빠름)


function this.OnStart()
    if this.IsVisibleOnStart then
        reset()
    end
end

local function touchedWall()

    iceWallLife = iceWallLife - 1

    if iceWallLife <= 0 then
        this.isBroken = true
    end

    updateIceWallActive()
end


local function dashedWall(secondStepMove)

    hasSecondStepMove = secondStepMove
    if not hasSecondStepMove then
        touchedWall()
    end

    local moved = currentWall.transform.forward * punchDistance
    local newPos = currentWall.transform.position + moved

    currentWall.transform.position = newPos

    wallVelocity = Vector3.zero
end

local nearMoved = 0.001


local function needSecondStepMove()
    return not hasSecondStepMove and updatedLocalPosition:SqrMagnitude() <= (nearMoved * nearMoved)
end



local function isFrontDash(character)
    local directionToTarget = Vector3.Normalize(currentWall.transform.position - character.transform.position)
    local dot = Vector3.Dot(character.transform.forward, directionToTarget)
    return dot > 0
end

local function delayedDisappear()
    VFramework.WaitForSeconds(0.2)
    this.visibleScript.Hide()

    if this.CanRespawn then
        VFramework.WaitForSeconds(this.RespawnDelay)
        reset()
        this.visibleScript.Show()
    end
end

local function breakIceWall()
    this.animator:SetBool('IsBroken', true)
    this.rootCollider.enabled = false
    playRandomSound(this.soundDoorBreak)
    shownBroken = true

    scriptObject:AsyncCall(delayedDisappear)
end

function this.OnUpdate(deltaTime)

    if currentWall == nil then return end

    if not this.isBroken then


        for _, character in pairs(enteredCharacter) do
            if character.isHeadButting then
                if not dashedCharacter[character] then
                    dashedCharacter[character] = true
                    if isFrontDash(character) then
                        print('character headbutting : ')
                        dashedWall(false)
                    end
                end
            else
                 dashedCharacter[character] = false
            end
        end


        updatedLocalPosition, wallVelocity = Vector3.SmoothDamp(
            currentWall.transform.localPosition,
            Vector3.zero,
            wallVelocity,
            returnTime
        );
        currentWall.transform.localPosition = updatedLocalPosition
               

        if needSecondStepMove() then
            dashedWall(true)
        end

        if this.isBroken then
            breakIceWall()
        end
    else
        if not shownBroken then
            breakIceWall()
        end
    end

end


function this.OnCollisionEnter(collision)   

    local ok, character = collision.vObject:CastByType(typeof(VFramework.Character))
    if ok then
        enteredCharacter[character.player.id] = character
        dashedCharacter[character] = false
    end

    print('character collision enter')
end

function this.OnCollisionExit(collision)
    
    local ok, character = collision.vObject:CastByType(typeof(VFramework.Character))
    if not ok then
        return
    end

    enteredCharacter[character.player.id] = nil
    dashedCharacter[character] = nil

    print('character collision exit')
end

__EX_FUNCTION__(this)
function this.Spawn()
    reset()
    this.visibleScript.Show()
end

