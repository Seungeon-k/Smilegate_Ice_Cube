local this = __CREATOR__.new()

local serviceApi
local scriptObject

this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
this.IsAutoStart = __EX_VARIABLE__.bool(true)
this.AutoStartDelay = __EX_VARIABLE__.float(1.0)
this.FireItem = __EX_VARIABLE__.vobject()
this.FireForce = __EX_VARIABLE__.float(300.0)
this.IsRepeating = __EX_VARIABLE__.bool(false)
this.FireInterval = __EX_VARIABLE__.float(1.0)

local visibleScript = nil
local cannonScript = nil

local autoStartTimer = 0
local isAutoStartPending = false
local fireIntervalTimer = 0
local isFiringRepeatedly = false

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
    
    local root = scriptObject.parent    
    
    local visibleObj = root:Find("VisibleModule/Visible_S")
    if visibleObj then
        visibleScript = visibleObj:GetLua()
    end    
    
    local cannonObj = root:Find("CannonModule/CannonFire_S")
    if cannonObj then
        cannonScript = cannonObj:GetLua()
    end

    if visibleScript then
        visibleScript.IsVisibleOnStart = this.IsVisibleOnStart
    end

    if cannonScript then            
        cannonScript.FireItem = this.FireItem
        cannonScript.FireForce = this.FireForce
    end
end

function this.OnStart()        
    if this.IsVisibleOnStart then
        this.Show()
    end
end

function this.OnUpdate(deltaTime)    
    if isAutoStartPending then        
        autoStartTimer = autoStartTimer - deltaTime
        if autoStartTimer <= 0 then
            isAutoStartPending = false
            this.Fire()
            
            if this.IsRepeating then
                isFiringRepeatedly = true
                fireIntervalTimer = this.FireInterval
            end
        end
    end

    if isFiringRepeatedly then        
        fireIntervalTimer = fireIntervalTimer - deltaTime
        if fireIntervalTimer <= 0 then
            fireIntervalTimer = this.FireInterval
            this.Fire()
        end
    end
end

function this.StartAutoFireSequence()    
    autoStartTimer = this.AutoStartDelay
    isAutoStartPending = true
end

function this.Fire()
    if not scriptObject.activeSelf then
        return
    end
    if cannonScript then
        cannonScript:Fire()
    end
end

__EX_FUNCTION__(this)
function this.Show()
    if not scriptObject.activeSelf then
            return
    end

    if visibleScript then
        visibleScript:Show()
    end
end

__EX_FUNCTION__(this)
function this.Hide()
    if not scriptObject.activeSelf then
            return
    end
    this.StopFire()
    if visibleScript then
        visibleScript:Hide()
    end
end
__EX_FUNCTION__(this)
function this.OnShowAutoStart()    
    if scriptObject.activeSelf and this.IsAutoStart then       
            this.StartAutoFireSequence()
    end      
end

__EX_FUNCTION__(this)
function this.StartFire()
    if not scriptObject.activeSelf then
            return
    end
    this.StartAutoFireSequence()
end

__EX_FUNCTION__(this)
function this.StopFire()
    if not scriptObject.activeSelf then
            return
    end
    isAutoStartPending = false
    isFiringRepeatedly = false
end