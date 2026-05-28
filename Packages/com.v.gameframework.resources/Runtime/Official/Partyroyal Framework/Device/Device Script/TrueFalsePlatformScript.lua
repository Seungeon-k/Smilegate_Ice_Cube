local this = __CREATOR__.new()

this.IsTruePlatform = __EX_VARIABLE__.bool(true)
this.TrueRevertDelay = __EX_VARIABLE__.float(2)
this.TrueRevertDuration = __EX_VARIABLE__.float(1)
this.TrueColorChangeDuration = __EX_VARIABLE__.float(2)
this.CanRespawn = __EX_VARIABLE__.bool(false)
this.RespawnDelay = __EX_VARIABLE__.float(5)


this.normalColor = __EX_VARIABLE__.color("007CB3FF")
this.trueColor = __EX_VARIABLE__.color("ED9B00FF")
this.colorTweenStep = __EX_VARIABLE__.float(0.03)

this.platform = __EX_VARIABLE__.vobject()
this.vfxDust = __EX_VARIABLE__.vobject()

this.soundTruePlatform = _VASSET_.audioClip()
this.soundFalsePlatform = _VASSET_.audioClip()

local serviceApi
local scriptObject
local soundService

local BASE_COLOR_KEY = '_BaseColor'
local propBinder
local currentColor

local function setColor(color)
    if propBinder then
        currentColor = color
        propBinder:SetColor(BASE_COLOR_KEY, color)
    end
end


function this.OnAwake()    
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
    soundService = serviceApi.soundService
    
end


function this.OnStart()
    if this.platform == nil then
        print('Platform object is nil')
        return
    end
    
    this.vfxDust:SetActive(false)

    local ok, binder = this.platform:GetComponentInChildrenByType(typeof(VFramework.MaterialPropertyBinder))
    if  ok then
        propBinder = binder
        propBinder:SetColor(BASE_COLOR_KEY, this.normalColor)
        currentColor = this.normalColor
    end
end

local asyncResetHandle = nil
local asyncResetHandleTween = nil
local asyncTrueHandle = nil
local asyncTrueHandleTween = nil


local function clearDelayResetColor()
    if asyncResetHandle ~= nil then
        asyncResetHandle:Stop()
        asyncResetHandle = nil
    end
end

local function clearTweenResetColor()
    if asyncResetHandleTween ~= nil then
        asyncResetHandleTween:Stop()
        asyncResetHandleTween = nil
    end
end

local function clearDelayTrueColor()
    if asyncTrueHandle ~= nil then
        asyncTrueHandle:Stop()
        asyncTrueHandle = nil
    end
end

local function clearTweenTrueColor()
    if asyncTrueHandleTween ~= nil then
        asyncTrueHandleTween:Stop()
        asyncTrueHandleTween = nil
    end
end

local function activatePlatform()
    this.platform:SetActive(true)
    this.vfxDust:SetActive(false)
end

local function deactivePlatform()
    this.platform:SetActive(false)
    this.vfxDust:SetActive(true)
end

local function tweenColor(from, to, duration, step, onValue, onComplete)
    local  elapsed = 0

    while elapsed < duration do
      elapsed = elapsed + step
      local t = elapsed / duration
      if t > 1 then t = 1 end

      local lerp = Color.Lerp(from, to, t)
      onValue(lerp)

      VFramework.WaitForSeconds(step)
    end

    if onComplete then onComplete() end
end



local function delayTrueColor()
     --VFramework.WaitForSeconds(this.TrueRevertDelay)
    
    -- setColor(this.normalColor)
    asyncTrueHandleTween = scriptObject:AsyncCall(function()
        local from = currentColor
        local to = this.trueColor
        local duration = this.TrueColorChangeDuration
        local step = this.colorTweenStep

        tweenColor(from, to, duration, step,
        function (lerpColor)
            setColor(lerpColor)
        end, 
        function() 
            print('tween color complete')
            asyncTrueHandleTween = nil
        end)
    end)

    asyncTrueHandle = nil
end

local function delayResetColor()
    VFramework.WaitForSeconds(this.TrueRevertDelay)
    
    -- setColor(this.normalColor)
    asyncResetHandleTween = scriptObject:AsyncCall(function()
        local from = currentColor
        local to = this.normalColor
        local duration = this.TrueRevertDuration
        local step = this.colorTweenStep

        tweenColor(from, to, duration, step,
        function (lerpColor)
            setColor(lerpColor)
        end, 
        function() 
            print('tween color complete')
            asyncResetHandleTween = nil
        end)
    end)

    asyncResetHandle = nil
end

local function delayRespawnPlatform()
    VFramework.WaitForSeconds(this.RespawnDelay)

    activatePlatform()
end

local enteredObjects = {}
local function countMap(t)
    local n = 0
    for k, v in pairs(t) do
        if v then
            n = n + 1
        end
    end
    return n
end

local function onCollisionTruePlatform()
    clearDelayResetColor()
    clearTweenResetColor()
    --setColor(this.trueColor)
    asyncTrueHandle = scriptObject:AsyncCall(delayTrueColor)
    soundService:Play(this.soundTruePlatform)
end

local function onCollisionFalsePlatform()
    
    deactivePlatform()
    soundService:Play(this.soundFalsePlatform)

    for k, _ in pairs(enteredObjects) do
        enteredObjects[k] = false
    end

    if this.CanRespawn then
        scriptObject:AsyncCall(delayRespawnPlatform)
    end
end



function this.OnCollisionEnter(collision)
    if enteredObjects[collision.vObject] then
        return
    end
    enteredObjects[collision.vObject] = true

    if this.IsTruePlatform then
        onCollisionTruePlatform()
    else
        onCollisionFalsePlatform()
    end
end

function this.OnCollisionExit(collision)
    if enteredObjects[collision.vObject] then
        enteredObjects[collision.vObject] = false

        local enteredCount = countMap(enteredObjects)
        if this.IsTruePlatform and enteredCount <= 0 then
            clearDelayTrueColor()
            clearTweenTrueColor()
            asyncResetHandle = scriptObject:AsyncCall(delayResetColor)
        end
    end
end

__EX_FUNCTION__(this)
function this.SetRandomTruthState()
    this.IsTruePlatform = math.random(0, 1) == 1
end

__EX_FUNCTION__(this)
function this.SetTrueState()
    this.IsTruePlatform = true
end

__EX_FUNCTION__(this)
function this.SetFalseState()
    this.IsTruePlatform = false
end

__EX_FUNCTION__(this)
function this.ResetTruthState()
    setColor(this.normalColor)
    activatePlatform()
end
