local this = __CREATOR__.new()

local script
local conveyorBeltScript

local cachedForceDir = nil
local renderers = nil
local isStarted = false

local SCROLL_PARAM = "_XScrollSpeed"
local pendingApplyScrollSpeed = false
local pendingApplyScrollSpeedValue = 0.0

local function LogError(message)
    if script ~= nil then
        script:Log(message)
    else
        print(message)
    end
end

local function GetControllerFlowSpeedFactor()
    if conveyorBeltScript == nil or conveyorBeltScript.GetFlowSpeedFactor == nil then
        return nil
    end
    return conveyorBeltScript.GetFlowSpeedFactor()
end

local function GetCachedForceDir()
    if cachedForceDir == nil then
        if script == nil then return nil end
        local parent = script.parent
        if parent == nil then return nil end

        local forward = parent.transform and parent.transform.forward or nil
        if forward ~= nil then
            cachedForceDir = forward.normalized
        end
    end
    return cachedForceDir
end

local function GetCharacterFromCollision(collision)
    if collision == nil then return nil end
    local obj = collision.vObject or collision
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

local function GetPlayerFromCollision(collision)
    local character = GetCharacterFromCollision(collision)
    if character == nil then return nil end
    return character.player
end

function this.OnAwake()
    script = this.scriptObject
    if script == nil then
        LogError("[ConveyorBeltSlot] scriptObject is nil.")
        return
    end

    local parent = script.parent
    if parent == nil then
        LogError("[ConveyorBeltSlot] parent is nil.")
        return
    end

    renderers = parent:GetComponentsInChildren("Renderer")

    GetCachedForceDir()
    if cachedForceDir == nil then
        LogError("[ConveyorBeltSlot] force direction cache failed.")
    end
end

function this.OnStart()
    isStarted = true
end

function this.OnTriggerEnter(collision)
--function this.OnCollisionEnter(collision)
    script:Log("OnTriggerEnter")
    if conveyorBeltScript == nil then return end

    local player = GetPlayerFromCollision(collision)
    if player == nil then return end

    if this.GetDirectionForce() == nil then return end
    conveyorBeltScript.Register(player, this)
end

function this.OnTriggerExit(collision)
--function this.OnCollisionExit(collision)
    script:Log("OnTriggerExit")
    if conveyorBeltScript == nil then return end

    local player = GetPlayerFromCollision(collision)
    if player == nil then return end

    conveyorBeltScript.UnRegister(player, this)
end

function this.OnDisable()
    if conveyorBeltScript == nil then return end
    if conveyorBeltScript.UnRegisterAllBySlot == nil then return end

    conveyorBeltScript.UnRegisterAllBySlot(this)
end

function this.GetDirectionForce()
    local forceDir = GetCachedForceDir()
    if forceDir == nil then return nil end
    local forceValue = conveyorBeltScript.GetForce()
    if forceValue == nil then return nil end
    return forceDir * forceValue
end

function this.SetConveyorBeltController(conveyorBeltVObj)
    if conveyorBeltVObj == nil then
        LogError("SetConveyorBeltController vobject is nil.")
        return
    end
    conveyorBeltScript = conveyorBeltVObj:GetLua()
    if conveyorBeltScript == nil then
        LogError("SetConveyorBeltController lua is nil.")
    end
end

local function SetFlowSpeed(value)   

    if renderers == nil then return end    

    for i = 1, #renderers do
        local r = renderers[i]
        if r ~= nil and r.materials ~= nil then
            for j = 1, #r.materials do
                local m = r.materials[j]
                if m ~= nil then
                    m:SetFloat(SCROLL_PARAM, value)
                end                
            end            
        end
    end
end

function this.OnUpdate(deltaTime)
    if isStarted == false then return end
    if pendingApplyScrollSpeed == true then
       SetFlowSpeed(pendingApplyScrollSpeedValue)
        pendingApplyScrollSpeed = false;
        pendingApplyScrollSpeedValue = 0.0  
    end        
end

function this.FlowPlay()        
    local flowSpeed = conveyorBeltScript.GetFlowSpeed()
    if flowSpeed == nil then
        return
    end
    
    if isStarted ==  false then
        pendingApplyScrollSpeed = true
        pendingApplyScrollSpeedValue = flowSpeed
        return
    end
    SetFlowSpeed(flowSpeed)
end

function this.FlowStop()
    if isStarted ==  false then
        pendingApplyScrollSpeed = true
        pendingApplyScrollSpeedValue = 0.0
        return
    end
    SetFlowSpeed(0.0)
end
