

local this = __CREATOR__.new()

local serviceApi
local script

local playerService
local soundService
local world



this.item = __EX_VARIABLE__.vobject()
this.throwObject = __EX_VARIABLE__.vobject()
this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
this.VisibleDelay = __EX_VARIABLE__.float(0)
this.force = __EX_VARIABLE__.float(10)
this.addtionalThrowingDirection = __EX_VARIABLE__.vector3(0, 0.8, 0)
this.throwSound = __EX_VARIABLE__.asset.audioClip()

local init = false
local delaytime = 0
local checkVisible = ture



function this.OnAwake()

    if this.item then
        this.item:SetWorldEnabled(this.IsVisibleOnStart)
    end
    
    checkVisible = this.IsVisibleOnStart
    
end


function this.OnStart()    
    if init == true then return end 
    init = true 
    
    serviceApi = this.serviceApi        
    script = this.scriptObject   
    

    playerService = serviceApi.playerService
    world = serviceApi.world
    soundService = serviceApi.soundService


    script.parent.OnAttackBegin:AddListener(this.OnAttackBegin)
    
    
end    

function this.OnUpdate(deltaTime)

    if checkVisible == true then return end

    delaytime = delaytime + deltaTime

    if delaytime >= this.VisibleDelay then
        checkVisible = true
        if this.item then
            this.item:SetWorldEnabled(true)
        end

    end
            
end


function this.OnAttackBegin(item)

    
    local myOwner = item:GetOwnerCharacter()
    if myOwner == nil then return end

    local pos = myOwner.transform.position
    pos = pos + myOwner.transform.rotation * Vector3(0, 1, 2)

    local th = world:Instantiate(this.throwObject, pos, Quaternion(0,0,0,1))


    local rd = th:GetComponent("Rigidbody")

    if not rd then return end

    local fo = myOwner.transform.forward + this.addtionalThrowingDirection
    fo = fo.normalized * this.force
    rd:AddForce(fo, VFramework.ForceMode.VelocityChange)


     if this.throwSound then
        soundService:Play(this.throwSound)
    end


end

__EX_FUNCTION__(this)
function this.AppearOnEvent()

    checkVisible = true
    if this.item then
        this.item:SetWorldEnabled(true)
    end
end



__EX_FUNCTION__(this)
function this.DisappearOnEvent()

    checkVisible = true
    if this.item then
        this.item:SetWorldEnabled(false)
    end
end


