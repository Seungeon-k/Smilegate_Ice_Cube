

local this = __CREATOR__.new()

local serviceApi
local scriptObject

local playerService
local physicService
local soundService

local currentDelay
local currentTime


this.AutoExplosion = __EX_VARIABLE__.bool(false)
this.ExplosionDelay = __EX_VARIABLE__.float(0)
this.ExplosionDuration = __EX_VARIABLE__.float(5)
this.ExplosionRadius = __EX_VARIABLE__.float(6)
this.ExplosionForce = __EX_VARIABLE__.float(100)
this.ReplaceKnockbackForceHeight = __EX_VARIABLE__.float(55)
this.PlayerForceMultiplier = __EX_VARIABLE__.float(1)
this.ExplosionObstructionMultiplier = __EX_VARIABLE__.float(1)
this.MaxExplosionForce = __EX_VARIABLE__.float(3500)
this.MaxPlayerKnockbackSpeed = __EX_VARIABLE__.float(35)
this.vfxPre = __EX_VARIABLE__.vobject()
this.vfxPreExplosion = __EX_VARIABLE__.vobject()
this.vfxPre1 = __EX_VARIABLE__.vobject()
this.vfxPre2 = __EX_VARIABLE__.vobject()
this.boomEffect = __EX_VARIABLE__.vobject()
this.boomSound = __EX_VARIABLE__.asset.audioClip()

local activated = false
local initVelocity = true
local bombState = 0
local bombObject
local baseRadius = 5.0
local scaleValue
local world



local function activate()

    if activated then return end

    activated = true
    
    --[[
    if initVelocity == true then
        bombObject = scriptObject.parent

        local ok, rd = bombObject:GetComponentByType(typeof(VFramework.Rigidbody))
        if ok then
            rd.velocity = Vector3(0,0,0)
            rd.angularVelocity = Vector3(0,0,0)

            initVelocity = false
        end
    end
    ]]--
end


local function OverlapBox(toGo, fromGo)
    local toGoPosition = toGo.transform.position
    local fromGoPosition = fromGo.transform.position

    local dir = (toGoPosition - fromGoPosition).normalized
    local dis = Vector3.Distance(toGoPosition, fromGoPosition)
    local rot = Quaternion.identity
    if dir ~= Vector3.zero then
        rot = Quaternion.LookRotation(dir)
    end

    local center = fromGoPosition + (dir * dis) * 0.5
    local size = Vector3(0.5, 0.5, dis*0.5)


    local colliders = physicService:OverlapBox(center, size, rot)

    return colliders

end

local function CalcOccludedFalloff(toGo, fromGo, power, decrementRate)
    
    local hits = OverlapBox(toGo, fromGo)
    local tmpPower = power

    if hits == nil or #hits == 0 then
        return tmpPower
    end

    for i = 1, #hits do
        local v = hits[i]
        local go = v.vObject
        if go ~= toGo and go ~= fromGo and v.isTrigger == false then
            tmpPower = tmpPower * decrementRate
        end
    end

    return tmpPower
    
end



local function explosion()

    this.vfxPre:SetActive(false)

    bombState = 4
    local pos = scriptObject.parent.transform.position
    local colliders = physicService:OverlapSphere(pos, this.ExplosionRadius)

    for i = 1, #colliders do
        local v = colliders[i]
        local go = v.vObject
        if go ~= scriptObject.parent then
            local ok, character = go:CastByType(typeof(VFramework.Character))
            local resultPower = CalcOccludedFalloff(go, scriptObject.parent, this.ExplosionForce, this.ExplosionObstructionMultiplier)
            if resultPower > this.MaxExplosionForce then
                resultPower = this.MaxExplosionForce
            end
            
            if not character then
                if v.attachedRigidbody then
                    v.attachedRigidbody:AddExplosionForce(resultPower, pos, this.ExplosionRadius, this.ReplaceKnockbackForceHeight, VFramework.ForceMode.Impulse);
                end
            else
                -- 캐릭터이면 Knockback 를 하고
                character:AddExplosionForce(resultPower, pos, this.ExplosionRadius, this.ReplaceKnockbackForceHeight, VFramework.ForceMode.Impulse, this.MaxPlayerKnockbackSpeed)
            end
            

        end
        
    end

    if this.boomEffect then
        local th = world:Instantiate(this.boomEffect, pos, Quaternion(0,0,0,1))
        th.transform.localScale = th.transform.localScale * scaleValue
    end

    if this.boomSound then
        soundService:Play(this.boomSound)
    end

    scriptObject.parent:Destroy()
end


function this.OnStart()    
    serviceApi = this.serviceApi        
    scriptObject = this.scriptObject   
    

    playerService = serviceApi.playerService
    physicService = serviceApi.physicsService
    soundService = serviceApi.soundService

    world = serviceApi.world

    scaleValue = this.ExplosionRadius / baseRadius
    
    this.vfxPreExplosion.transform.localScale = this.vfxPreExplosion.transform.localScale * scaleValue
end

function this.OnEnable()
    currentDelay = this.ExplosionDelay
    currentTime = this.ExplosionDuration
end

local function delayedDisplayCircle()
    VFramework.WaitForSeconds(1)

    this.vfxPre:SetActive(true)
end

function this.OnUpdate(deltaTime)    

    if activated == false then

        --자동시작이 아니라면 무조건 activate() 호출되어야함
        if this.AutoExplosion == false then return end

        currentDelay = currentDelay - deltaTime

        if currentDelay <= 0 then
            activate()
        end

        return
    end

    currentTime = currentTime - deltaTime

    if bombState == 3 then
        if currentTime <= 0 then

            explosion()

        end
    end

    if bombState == 2 then
        if currentTime <= 1 then
            bombState = 3
        end
    end

    if bombState == 1 then
        if currentTime <= 1 then
            this.vfxPre1:SetActive(false)
            this.vfxPre2:SetActive(true)
            bombState = 2
        end
    end

    if bombState == 0 then
        this.vfxPre1:SetActive(true)
        scriptObject:AsyncCall(delayedDisplayCircle)
        bombState = 1
    end


end

--[[
function this.OnCollisionEnter(collision)
    activate()
end
]]--

__EX_FUNCTION__(this)
function this.ForceStartExplosion()
    activate()
end


