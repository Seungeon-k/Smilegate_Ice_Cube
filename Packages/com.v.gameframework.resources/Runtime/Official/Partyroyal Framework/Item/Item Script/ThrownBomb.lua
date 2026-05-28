

local this = __CREATOR__.new()

local serviceApi
local script

local playerService
local physicService
local soundService

local currentTime

this.activateOnEnable = __EX_VARIABLE__.bool(false)
this.activateOnCollision = __EX_VARIABLE__.bool(true)
this.autoDestory = __EX_VARIABLE__.bool(true)
this.bombTime = __EX_VARIABLE__.float(5)
this.bombrange = __EX_VARIABLE__.float(6)
this.explosionForce = __EX_VARIABLE__.float(100)
this.replaceKnockbackForceHeight = __EX_VARIABLE__.float(55)
this.explosionMaxSpeed = __EX_VARIABLE__.float(0)
this.vfxPre = __EX_VARIABLE__.vobject()
this.vfxPre1 = __EX_VARIABLE__.vobject()
this.vfxPre2 = __EX_VARIABLE__.vobject()
this.boomEffect = __EX_VARIABLE__.vobject()
this.boomSound = __EX_VARIABLE__.asset.audioClip()


this.OnBombExploded = __EX_VARIABLE__.event()

local active = false
local exploded = false
local initVelocity = true
local boobState = 0
local bombObject
local isStart = false


local world


local function Init()

    currentTime = this.bombTime
    boobState = 0
    active = false
    exploded = false
    initVelocity = true
    this.vfxPre:SetActive(false)
    this.vfxPre1:SetActive(false)
    this.vfxPre2:SetActive(false)
    
end

local function Start()
    if currentTime == nil then
        Init()
    end
    active = true
end

local function Stop()
    active = false
end

function this.Restart()
    Init() 
    Start()
end

function this.ContinueWithTime(continueTime)
     active = true

     currentTime = continueTime


     if boobState == 0 then
        this.vfxPre1:SetActive(true)
        boobState = 1
     end

     if boobState == 1 then
        if currentTime <= 1 then
            this.vfxPre1:SetActive(false)
            this.vfxPre2:SetActive(true)
            this.vfxPre:SetActive(true)
            boobState = 2
        end
    end

    if boobState == 2 then
        if currentTime <= 1 then
            boobState = 3
        end
    end


end

function this.GetLeftTime()
    return currentTime
end


function this.OnStart()    
    serviceApi = this.serviceApi        
    script = this.scriptObject   
    

    playerService = serviceApi.playerService
    physicService = serviceApi.physicsService
    soundService = serviceApi.soundService

    world = serviceApi.world

    isStart = true

    if active == false then
        Init() 
    end

end    

function this.OnEnable()    

    if this.activateOnEnable then
        Start()
    end
end

function this.OnDisable()
    Stop()
end



function this.OnUpdate(deltaTime)

    if active == false then return end
    if exploded == true then return end 

    currentTime = currentTime - deltaTime

    if boobState == 3 then
        if currentTime <= 0 then

            this.vfxPre:SetActive(false)
            boobState = 4
            local pos = script.parent.transform.position
            local colliders = physicService:OverlapSphere(pos, this.bombrange)

            for i = 1, #colliders do
                local v = colliders[i]
                local go = v.vObject
                if go ~= script.parent then
                    local character = go:Cast("Character") 
                    if not character then
                        if v.attachedRigidbody then
                            v.attachedRigidbody:AddExplosionForce(this.explosionForce, pos, this.bombrange, 0.55, VFramework.ForceMode.Impulse);
                        end
                    else
                        -- 캐릭터이면 Knockback 를 하고
                        character:AddExplosionForce(this.explosionForce, pos, this.bombrange, this.replaceKnockbackForceHeight, VFramework.ForceMode.Impulse, this.explosionMaxSpeed)
                    end


                end
                
            end

            if this.boomEffect then
                local th = world:Instantiate(this.boomEffect, pos, Quaternion(0,0,0,1))

            end

            if this.boomSound then
                soundService:Play(this.boomSound)
            end

            exploded = true 
            this.OnBombExploded:Call()


            if this.autoDestory then
                script.parent:Destroy()
            end

            


        end
    end

    if boobState == 2 then
        if currentTime <= 1 then
            boobState = 3
        end
    end

    if boobState == 1 then
        if currentTime <= 1 then
            this.vfxPre1:SetActive(false)
            this.vfxPre2:SetActive(true)
            this.vfxPre:SetActive(true)
            boobState = 2
        end
    end

     if boobState == 0 then
        this.vfxPre1:SetActive(true)
        boobState = 1
     end


end


function this.OnCollisionEnter(collision)

    if active then return end
    if exploded then return end
    if this.activateOnCollision == false then return end
    if isStart == false then return end

      

    active = true 
    
    if initVelocity == true then
        bombObject = script.parent

        local rd = bombObject:GetComponent('Rigidbody')
        rd.velocity = Vector3(0,0,0)
        rd.angularVelocity = Vector3(0,0,0)


        initVelocity = false


    end

    
end


