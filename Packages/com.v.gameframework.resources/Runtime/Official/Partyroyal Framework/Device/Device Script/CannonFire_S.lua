local this = __CREATOR__.new()

local serviceApi, scriptObject
this.FireOrigin = __EX_VARIABLE__.vobject()
this.FireItem = __EX_VARIABLE__.vobject()
this.FireForce = __EX_VARIABLE__.float(100.0)
this.TorqueImpulse = __EX_VARIABLE__.float(200.0)
this.OnFire = __EX_VARIABLE__.event()

local animator = nil
local FIRE_STATE = "CannonFire"
local FIRE_TIME, RESET_TIME = 0.8, 0.95
local hasFired = false 

function this.OnAwake()
    serviceApi, scriptObject = this.serviceApi, this.scriptObject
    local animatorRoot = scriptObject.parent.parent:Find("Party_Cannon")
    if animatorRoot then animator = animatorRoot:GetComponent("Animator") end
end

function this.OnUpdate(dt)    
    if not animator then return end
    local state = animator:GetCurrentAnimatorStateInfo(0)
    if state:IsName(FIRE_STATE) then
        local progress = state.normalizedTime % 1.0
        if not hasFired and progress >= FIRE_TIME and progress < RESET_TIME then
            hasFired = true            
            this.SpawnProjectile()
        end

        if progress >= RESET_TIME then animator:SetBool("IsCannon_Fire", false) end
    else
        hasFired = false
    end
end

function this.Fire()       
    if not (this.FireItem and this.FireOrigin and animator) then return end

    local state = animator:GetCurrentAnimatorStateInfo(0)
    if state:IsName(FIRE_STATE) and (state.normalizedTime % 1.0) < RESET_TIME then return end

    hasFired = false 
    animator:SetBool("IsCannon_Fire", true)
end

function this.SpawnProjectile()    
    local item = serviceApi.world:Instantiate(this.FireItem, this.FireOrigin.transform.position, this.FireOrigin.transform.rotation)
    if not item then return end

    local body = item:GetComponent("Rigidbody")
    if body then
        body:AddForce(this.FireOrigin.transform.forward * this.FireForce, VFramework.ForceMode.Impulse)
        body:AddTorque(this.FireOrigin.transform.right * this.TorqueImpulse, VFramework.ForceMode.Impulse)
    end
    this.OnFire:Call()
end