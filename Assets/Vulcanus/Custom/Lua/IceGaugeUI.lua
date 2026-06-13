local this = __CREATOR__.new()

this.IceCubeName = __EX_VARIABLE__.string("Ice_Cube")
this.GaugeSlider = __EX_VARIABLE__.component.slider()
this.SmoothSpeed = __EX_VARIABLE__.float(10.0)

local world = nil
local iceCube = nil
local initialHeight = 0
local displayedRatio = 1

-- Keep the HUD value within the Slider's normalized range.
local function clamp01(value)
    if value < 0 then
        return 0
    end

    if value > 1 then
        return 1
    end

    return value
end

local function resolveIceCube()
    if iceCube ~= nil and iceCube.transform ~= nil then
        return true
    end

    if world == nil then
        return false
    end

    iceCube = world:GetVObject(this.IceCubeName)
    if iceCube == nil or iceCube.transform == nil then
        return false
    end

    initialHeight = iceCube.transform.localScale.y
    return initialHeight > 0
end

function this.OnAwake()
    if this.serviceApi ~= nil then
        world = this.serviceApi.world
    end
end

function this.OnStart()
    resolveIceCube()

    if this.GaugeSlider ~= nil then
        this.GaugeSlider.value = 1
    end
end

function this.OnUpdate(deltaTime)
    if this.GaugeSlider == nil or not resolveIceCube() or initialHeight <= 0 then
        return
    end

    local targetRatio = clamp01(iceCube.transform.localScale.y / initialHeight)
    local speed = this.SmoothSpeed or 10
    local blend = clamp01(speed * deltaTime)

    displayedRatio = displayedRatio + (targetRatio - displayedRatio) * blend
    this.GaugeSlider.value = displayedRatio
end
