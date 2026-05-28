local this = __CREATOR__.new()

local script
local animator
local isOn = false
local isWaitingAnimEnd = false
local pendingEventOn = false
local waitingTargetState = false
local pendingStateHash = nil
local onStateHash = nil
local offStateHash = nil

this.IsOnStart = __EX_VARIABLE__.bool(true)
this.TurnOnAniName = __EX_VARIABLE__.string("On")
this.TurnOffAniName = __EX_VARIABLE__.string("Off")
this.OnTurnOnEvent = __EX_VARIABLE__.event()
this.OnTurnOffEvent = __EX_VARIABLE__.event()
this.OnChangeState = __EX_VARIABLE__.event(__EX_VARIABLE__.bool())
this.OnTurnOnLeverTex = __EX_VARIABLE__.asset.texture()
this.OnTurnOffLeverTex = __EX_VARIABLE__.asset.texture()

local renderer = nil

local function CacheRenderer()
    if renderer ~= nil then
        return
    end

    local leverObj = script.parent:Find("Mesh/Lever/GD_Lever")
    if leverObj ~= nil then
        renderer = leverObj:GetComponent("Renderer")
    end    
end

local function ChangeKnob()
    if renderer == nil then
        return
    end

    local tex = nil
    if isOn == true then
        tex = this.OnTurnOnLeverTex
    else
        tex = this.OnTurnOffLeverTex
    end 

    if tex == nil then
        return
    end

    if #renderer.materials > 1 and renderer.materials[2] ~= nil then
        renderer.materials[2]:SetTexture("_BaseMap", tex)
    else
        if renderer.material ~= nil then
            renderer.material:SetTexture("_BaseMap", tex)
        end
    end
end

local function LogError(message)
    if script ~= nil then
        script:Log(message)
    else
        print(message)
    end
end

local function GetCharacterFromCollision(collider)
    if collider == nil then return nil end
    local obj = collider.vObject or collider
    if obj == nil then return nil end

    local character = obj:Cast("Character")
    if character ~= nil then
        return character
    end

    local ok, byType = obj:CastByType(typeof(VFramework.Character))
    if ok then
        return byType
    end

    return nil
end

local function Play()
    if animator == nil then
        LogError("[Lever] animator is nil.")
        return
    end    
    --animator:Play(stateName, 0, 0)
    animator:SetBool("on", isOn)
end

local function IsTargetState(stateInfo)
    if pendingStateHash == nil or stateInfo == nil then return false end
    return (stateInfo.shortNameHash == pendingStateHash) or (stateInfo.fullPathHash == pendingStateHash)
end

local function FirePendingEvent()
    isWaitingAnimEnd = false
    waitingTargetState = false

    ChangeKnob()

    if pendingEventOn then
        if script ~= nil then
            script:Log("[Lever] OnTurnOnEvent")
        end
        if this.OnTurnOnEvent ~= nil then
            this.OnTurnOnEvent:Call()
        end
    else
        if script ~= nil then
            script:Log("[Lever] OnTurnOffEvent")
        end
        if this.OnTurnOffEvent ~= nil then
            this.OnTurnOffEvent:Call()
        end
    end
end

function this.OnAwake()
    script = this.scriptObject
    if script == nil then
        LogError("[Lever] scriptObject is nil.")
        return
    end
    animator = script.parent:GetComponentInChildren("Animator")
    if animator == nil then
        LogError("[Lever] Animator is nil.")
    end

    CacheRenderer()

    if this.TurnOnAniName ~= nil and this.TurnOnAniName ~= "" then
        onStateHash = VFramework.Animator.StringToHash(this.TurnOnAniName)
    end
    if this.TurnOffAniName ~= nil and this.TurnOffAniName ~= "" then
        offStateHash = VFramework.Animator.StringToHash(this.TurnOffAniName)
    end
end

function this.OnStart()
    isOn = this.IsOnStart
    Play()
    ChangeKnob()
end

local function ApplyState(nextIsOn)
    if isOn == nextIsOn then return end
    isOn = nextIsOn
    Play()
    isWaitingAnimEnd = true
    pendingEventOn = nextIsOn
    waitingTargetState = true
    pendingStateHash = nextIsOn and onStateHash or offStateHash

    if this.OnChangeState ~= nil then
        this.OnChangeState:Call(isOn)
    end
end

function this.OnUpdate(deltaTime)
    if isWaitingAnimEnd == false then return end
    if animator == nil then return end

    local stateInfo = animator:GetCurrentAnimatorStateInfo(0)
    if stateInfo == nil then return end

    local inTarget = IsTargetState(stateInfo)
    if waitingTargetState then
        if inTarget then
            waitingTargetState = false
            if stateInfo.normalizedTime >= 0.97 then
                FirePendingEvent()
            end
        end
        return
    end

    if inTarget then
        if stateInfo.normalizedTime >= 0.97 then
            FirePendingEvent()
        end
    else
        -- Target animation already finished or transitioned out.
        FirePendingEvent()
    end
end

__EX_FUNCTION__(this)
function this.TurnOn()
    ApplyState(true)
end

__EX_FUNCTION__(this)
function this.TurnOff()
    ApplyState(false)
end

function this.OnTriggerEnter(collider)
    local character = GetCharacterFromCollision(collider)
    if character == nil then return end

    ApplyState(not isOn)
end
