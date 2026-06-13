local this = __CREATOR__.new()

local ICE_CUBE_NAME = "Ice_Cube"
local GAUGE_UI_PATH = "IceGaugeHUD_UI/IceGaugeSlider"
local GAUGE_UI_NAME = "IceGaugeSlider"
local INITIAL_HEIGHT = 3.0028605
local SMOOTH_SPEED = 10.0

local serviceApi = nil
local scriptObject = nil
local world = nil
local uiService = nil
local iceCube = nil
local gaugeSlider = nil
local displayedRatio = 1.0

local function clamp01(value)
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
end

local function log(message)
    if scriptObject ~= nil then
        scriptObject:Log("[IceGaugeController] " .. message)
    end
end

local function resolveGauge()
    if gaugeSlider ~= nil then
        return true
    end

    if uiService == nil then
        return false
    end

    local gaugeObject = uiService:GetChildUI(GAUGE_UI_PATH)
    if gaugeObject == nil then
        gaugeObject = uiService:FindByName(GAUGE_UI_NAME)
    end

    if gaugeObject == nil then
        return false
    end

    gaugeSlider = gaugeObject:GetComponent("Slider")
    if gaugeSlider == nil then
        return false
    end

    gaugeSlider.normalizedValue = displayedRatio
    log("Gauge slider connected.")
    return true
end

local function resolveIceCube()
    if iceCube ~= nil and iceCube.transform ~= nil then
        return true
    end

    if world == nil then
        return false
    end

    iceCube = world:GetVObject(ICE_CUBE_NAME)
    if iceCube == nil or iceCube.transform == nil then
        return false
    end

    log("Ice_Cube connected.")
    return true
end

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject

    if serviceApi ~= nil then
        world = serviceApi.world
        uiService = serviceApi.uiService
    end
end

function this.OnStart()
    resolveGauge()
    resolveIceCube()
end

function this.OnUpdate(deltaTime)
    if not resolveGauge() or not resolveIceCube() then
        return
    end

    local currentHeight = iceCube.transform.localScale.y
    local targetRatio = clamp01(currentHeight / INITIAL_HEIGHT)
    local blend = clamp01(SMOOTH_SPEED * (deltaTime or 0.016))

    displayedRatio = displayedRatio + (targetRatio - displayedRatio) * blend
    gaugeSlider.normalizedValue = displayedRatio
end
