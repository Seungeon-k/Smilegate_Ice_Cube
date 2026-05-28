local this = __CREATOR__.new()

local serviceApi
local script
local targetTransform

this.AutoStart = __EX_VARIABLE__.bool(true)
this.ClockWise = __EX_VARIABLE__.bool(true)
local duration = 5
local loop = true
local pingPong = false
local cycleDelay = 0.0
local rotationDelta = nil

-- this.EaseInSine = __EX_VARIABLE__.bool(false) -- 사인 In 이징
-- this.EaseOutSine = __EX_VARIABLE__.bool(false) -- 사인 Out 이징
-- this.EaseInOutSine = __EX_VARIABLE__.bool(false) -- 사인 InOut 이징
-- this.EaseInCubic = __EX_VARIABLE__.bool(false) -- 큐빅 In 이징
-- this.EaseOutCubic = __EX_VARIABLE__.bool(false) -- 큐빅 Out 이징
-- this.EaseInOutCubic = __EX_VARIABLE__.bool(false) -- 큐빅 InOut 이징
local easeInSine = false -- 사인 In 이징
local easeOutSine = false -- 사인 Out 이징
local easeInOutSine = false -- 사인 InOut 이징
local easeInCubic = false -- 큐빅 In 이징
local easeOutCubic = false -- 큐빅 Out 이징
local easeInOutCubic = false -- 큐빅 InOut 이징

--this.OnStartEvent = __EX_VARIABLE__.event()

local elapsed = 0
local delayTimer = 0
local isPlaying = false
local isReversed = false
local isStarted = false
local initStartEuler = nil
local initTargetEuler = nil
local addType = true
local rigidBody = nil

local function Clamp01(value)
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
end

local function Pow(base, exponent)
    if exponent == 0 then return 1 end

    if exponent < 0 then
        base = 1 / base
        exponent = -exponent
    end

    local result = 1
    while exponent > 0 do
        if exponent % 2 == 1 then
            result = result * base
        end
        base = base * base
        exponent = math.floor(exponent / 2)
    end
    return result
end

--[[local function ApplyEase(t)
    if this.EaseInSine then
        return 1 - Mathf.Cos((t * math.pi) / 2)
    end
    if this.EaseOutSine then
        return Mathf.Sin((t * math.pi) / 2)
    end
    if this.EaseInOutSine then
        return -(Mathf.Cos(math.pi * t) - 1) / 2
    end
    if this.EaseInCubic then
        return t * t * t
    end
    if this.EaseOutCubic then
        return 1 - Pow(1 - t, 3)
    end
    if this.EaseInOutCubic then
        if t < 0.5 then
            return 4 * t * t * t
        end
        return 1 - Pow(-2 * t + 2, 3) / 2
    end
    return t
end]]--

local function ApplyEase(t)
    if easeInSine then
        return 1 - Mathf.Cos((t * math.pi) / 2)
    end
    if easeOutSine then
        return Mathf.Sin((t * math.pi) / 2)
    end
    if easeInOutSine then
        return -(Mathf.Cos(math.pi * t) - 1) / 2
    end
    if easeInCubic then
        return t * t * t
    end
    if easeOutCubic then
        return 1 - Pow(1 - t, 3)
    end
    if easeInOutCubic then
        if t < 0.5 then
            return 4 * t * t * t
        end
        return 1 - Pow(-2 * t + 2, 3) / 2
    end
    return t
end

local function ApplyTween(t)
    if targetTransform == nil then return end

    local lerpT = t
    if isReversed then
        lerpT = 1 - lerpT
    end

    local euler = initStartEuler + (initTargetEuler - initStartEuler) * lerpT
    if rigidBody ~= nil then
        rigidBody:MoveRotation(Quaternion.Euler(euler))
    else
        targetTransform.rotation = Quaternion.Euler(euler)
    end
end

function this.OnStart()

    serviceApi = this.serviceApi
    script = this.scriptObject
    targetTransform = script.parent.transform
    rigidBody = script.parent:GetComponent("Rigidbody")

    if this.ClockWise then
        rotationDelta = Vector3(0, 360, 0)
    else
        rotationDelta = Vector3(0, -360, 0)

    end
    

    if this.AutoStart then
        this.Play()
    end

end

--function this.OnUpdate(deltaTime)
function this.OnFixedUpdate( deltaTime)
    if isPlaying == false then return end
    if duration < 0 then return end

    if delayTimer > 0 then
        delayTimer = delayTimer - deltaTime
        if delayTimer > 0 then
            return
        end
        delayTimer = 0
    end

    if isStarted == false then
        isStarted = true
        ApplyTween(0)
        --if this.OnStartEvent ~= nil then
        --    this.OnStartEvent:Call()
        --end
    end

    elapsed = elapsed + deltaTime
    local t = Clamp01(elapsed / duration)
    local easeT = ApplyEase(t)

    ApplyTween(easeT)

    if elapsed >= duration then
        if loop then
            this.UpdateLoopFinish()
        else
            if pingPong then
                this.UpdatePingPong()
            else
                isPlaying = false                
            end
        end
    end
end

function this.UpdatePingPong()
    if pingPong == false then return end
    if elapsed < cycleDelay and cycleDelay > 0 then return end

    isReversed = not isReversed
    delayTimer = cycleDelay
    elapsed = 0    

    isStarted = false

    if isReversed == false then
        if loop == false then
            isPlaying = false
        end
    end
end

function this.UpdateLoopFinish()
    local isFinish = false
    if pingPong then
        this.UpdatePingPong()
    else
        delayTimer = cycleDelay
        isStarted = false
        if addType then
            initStartEuler = targetTransform.eulerAngles
            initTargetEuler = initStartEuler + rotationDelta
        end

        isFinish = true
    end

    elapsed = 0    
end

__EX_FUNCTION__(this)
function this.Play()

    initStartEuler = targetTransform.eulerAngles
    initTargetEuler = initStartEuler + rotationDelta
    elapsed = 0
    isReversed = false
    isPlaying = true
    isStarted = false
    delayTimer = 0

    ApplyTween(0)

end

__EX_FUNCTION__(this)
function this.Stop()
    isPlaying = false
end
