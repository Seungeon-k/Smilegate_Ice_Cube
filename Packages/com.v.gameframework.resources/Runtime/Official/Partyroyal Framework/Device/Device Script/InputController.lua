local this = __CREATOR__.new()

local serviceApi
local inputService
local inputGate
local cursor
local world
local uiService
local platformService
local bubblyzService
local script
local inputCameraType
local inputGameplayType

this.AllControlTargetObjects = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())

this.ControlledScriptObjectsForMobile = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject.script():lua())
this.ControlledScriptObjectsForPC = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject.script():lua())
this.ControlledScriptObjectsForConsole = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject.script():lua())

this.AlwaysDisableObjectsForMobile = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())
this.AlwaysDisableObjectsForPC = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())
this.AlwaysDisableObjectsForConsole = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())

this.MouseLookKeyActionName = __EX_VARIABLE__.string("MouseLook")
this.CameraName = __EX_VARIABLE__.string("BackViewController")
this.CursorIcon2D = __EX_VARIABLE__.asset.texture2D()
--this.CursorTexture2D = __EX_VARIABLE__.asset.texture2D()

local platformDisableSet = {}
local inputViewSet = {}
local inputViewScripts = {}
local touchEffectScript = nil

local isKeyPressForMouseLookState = false
local isApplicationFocus = true
local isApplicationPause = false
local isOpenMouseLookModeUI = false
local cachedPlatformKey = "default"
local isStarted = false
local needApplyUiAfterStart = false
local keyGuideEnable = true
local dirtyKeyGuideEnable = false
local enableMouseCursorLock = true
local keyGuideScripts = {}
local uiLayoutModifiers = {}
local camera = nil
local isTempHideControlUI = false

local function AddScriptViewUnique(list, seen, scriptObj)
    if scriptObj == nil then
        return
    end
    if seen[scriptObj] == true then
        return
    end
    seen[scriptObj] = true
    table.insert(list, scriptObj)
end

local function BuildSetFromList(list)
    local set = {}
    if list == nil then
        return set
    end
    for i = 1, #list do
        local obj = list[i]
        if obj ~= nil then
            set[obj] = true
        end
    end
    return set
end

local function MergeSet(dst, src)
    for obj, _ in pairs(src) do
        dst[obj] = true
    end
end

local function AddUniqueObject(list, obj)
    if list == nil or obj == nil then
        return
    end

    for i = 1, #list do
        if list[i] == obj then
            return
        end
    end

    local appended = pcall(function()
        list[#list + 1] = obj
    end)

    if appended == true then
        return
    end

    if list.Add ~= nil then
        pcall(function()
            list:Add(obj)
        end)
    end
end

local function FindChildLuaScript(parentObj, childName)
    if parentObj == nil or childName == nil then
        return nil
    end

    local child = parentObj:Find(childName)
    if child == nil then
        return nil
    end

    if child.GetLua ~= nil then
        return child:GetLua()
    end

    return nil
end

local function RebuildTrackedSets()
    inputViewSet = {}

    local setFromInputViews = BuildSetFromList(this.AllControlTargetObjects)
    MergeSet(inputViewSet, setFromInputViews)
end

local function AddScriptViewsFromList(list, scriptSeen)
    if list == nil then
        return
    end

    for i = 1, #list do
        AddScriptViewUnique(inputViewScripts, scriptSeen, list[i])
    end
end

local function RebuildScriptObjectsTable(platformKey)
    inputViewScripts = {}
    local scriptSeen = {}

    if platformKey == "mobile" then
        AddScriptViewsFromList(this.ControlledScriptObjectsForMobile, scriptSeen)
    elseif platformKey == "pc" then
        AddScriptViewsFromList(this.ControlledScriptObjectsForPC, scriptSeen)
    elseif platformKey == "console" then
        AddScriptViewsFromList(this.ControlledScriptObjectsForConsole, scriptSeen)
    else
        -- Fallback for unknown runtime: use PC set.
        AddScriptViewsFromList(this.ControlledScriptObjectsForPC, scriptSeen)
    end
end

local function RebuildPlatformDisableSet(platformKey)
    platformDisableSet = {}
    if platformKey == "mobile" then
        MergeSet(platformDisableSet, BuildSetFromList(this.AlwaysDisableObjectsForMobile))
    elseif platformKey == "pc" then
        MergeSet(platformDisableSet, BuildSetFromList(this.AlwaysDisableObjectsForPC))
    elseif platformKey == "console" then
        MergeSet(platformDisableSet, BuildSetFromList(this.AlwaysDisableObjectsForConsole))
    end
end

local function GetPlatformKey()
    if platformService ~= nil then
        if platformService.isMobile == true then
            return "mobile"
        end
        if platformService.isDesktop == true then
            return "pc"
        end
        if platformService.isConsole == true then
            return "console"
        end
    end
    return "default"
end

local function RebindInputRefsByPlatform()
    local platformKey = cachedPlatformKey
    if inputService ~= nil then
        inputService.OnButtonActionEvent:RemoveListener(this.OnButtonEvent)
    end

    inputGate = nil
    cursor = nil

    if serviceApi ~= nil then
        inputService = serviceApi.inputService
    else
        inputService = nil
    end

    if inputService == nil then
        return
    end

    if platformKey == "mobile" or platformKey == "pc" or platformKey == "console" then
        inputGate = inputService.gate
    end

    if platformKey == "pc" then
        cursor = inputService.cursor
    end

    if inputService ~= nil then
        inputService.OnButtonActionEvent:AddListener(this.OnButtonEvent)
    end
end

__EX_FUNCTION__(this)
function this.ApplyByBlockState()
    this.ApplyUIScriptCall()
    this.ApplyAllVObjects()
    this.ApplyCursorState()
    this.ApplyCameraControlMode()
end

local function ForceDisableAlwaysDisabledObjects()    
    for target, _ in pairs(platformDisableSet) do
        if target ~= nil then
            target:SetActive(false)
        end
    end
end

local function GetInputGateBlocked(channel)
    if inputGate == nil or channel == nil then
        return false
    end
    return inputGate:IsBlocked(channel) == true
end

local function ApplyVObjectState(target, state)
    if target == nil then
        return
    end

    if platformDisableSet[target] == true then
        return
    end

    target:SetActive(state)
end

function this.ApplyAllVObjects()
    local gameplayBlocked = GetInputGateBlocked(inputGameplayType)
    local isHideState = gameplayBlocked or isTempHideControlUI
    for target, _ in pairs(inputViewSet) do
        ApplyVObjectState(target, isHideState == false)
    end

    -- AlwaysDisable* resources must remain disabled after input-view state updates.
    ForceDisableAlwaysDisabledObjects()
end

local function CacheInputGateChannels()
    inputGameplayType = nil
    inputCameraType = nil
    if VFramework.InputChannel == nil then
        return
    end

    inputGameplayType = VFramework.InputChannel.Gameplay
    inputCameraType = VFramework.InputChannel.Camera
end

local function CacheTouchEffectScript()
    if world == nil then
        return
    end

    --local scriptObj = world:FindByName("TouchEffectScript_C")
    local scriptObj = uiService:FindByName("TouchEffectScript_C")
    if scriptObj ~= nil then
        touchEffectScript = scriptObj:GetLua()
    end
end

local function CacheKeyGuideScripts()
    if uiService == nil then
        return
    end

    local hotKeyObjs = uiService:FindAllByName("HotKeyScript_C")
    if hotKeyObjs == nil then
        return
    end

    local isNeedHide = true
    if cachedPlatformKey == "pc" then
        isNeedHide = false
    end

    for i, v in ipairs(hotKeyObjs) do
        local keyGuideScript = hotKeyObjs[i]:GetLua()
        if keyGuideScript ~= nil then
            table.insert(keyGuideScripts, keyGuideScript)
            if isNeedHide == true then
                keyGuideScript.Hide()                
                keyGuideScript.EnableHotKeyByPlatform(false)
            end
        end
    end
end

local function CacheUILayoutModifiers()
    if uiService == nil then
        return
    end

    local modifiers = uiService:FindAllByName("UIObjectLayoutModifier_C")
    if modifiers == nil then
        return
    end    

    for i, v in ipairs(modifiers) do
        local modifierScript = modifiers[i]:GetLua()
        if modifierScript ~= nil then
            table.insert(uiLayoutModifiers, modifierScript)            
        end
    end
end

function this.ApplyUIScriptCall()
    local gameplayBlocked = GetInputGateBlocked(inputGameplayType)
    local isHideControl = gameplayBlocked or isTempHideControlUI

    for i = 1, #inputViewScripts do
        local viewScript = inputViewScripts[i]
        if viewScript ~= nil then
            if isHideControl then
                if viewScript.HideByInputControl ~= nil then
                    viewScript.HideByInputControl()
                end
            else
                if viewScript.ShowByInputControl ~= nil then
                    viewScript.ShowByInputControl()
                end
            end
        end
    end
end

local function IsButtonPressed(buttonState)
    if buttonState == nil then
        return false
    end
    if VFramework ~= nil and VFramework.ButtonState ~= nil and buttonState == VFramework.ButtonState.Press then
        return true
    end
    --return buttonState == "Press" or buttonState == "Preses"
    return false
end

local function IsButtonReleased(buttonState)
    if buttonState == nil then
        return false
    end
    if VFramework ~= nil and VFramework.ButtonState ~= nil and buttonState == VFramework.ButtonState.Release then
        return true
    end
    --return buttonState == "Release"
    return false
end

local function IsCurrentMouseLookState()
    if isApplicationPause == true or isApplicationFocus == false then
        return true
    end

    if GetInputGateBlocked(inputGameplayType) == false then
        return false
    end
    
    return isKeyPressForMouseLookState == true or isOpenMouseLookModeUI == true
end

__EX_FUNCTION__(this)
function this.ApplyCursorState()
    if cursor == nil then
        return
    end

    if cachedPlatformKey ~= "pc" then
        return
    end

    if IsCurrentMouseLookState() == true then        
        cursor:SetPointer(enableMouseCursorLock, true)
        this.ChangeTouchEffectState(true)
        return
    end

    cursor:SetCaptured()
    this.ChangeTouchEffectState(false)    
end

function this.ChangeTouchEffectState(state)
    if touchEffectScript ~= nil then
        if state then            
            touchEffectScript.EnableEffect()
        else            
            touchEffectScript.DisableEffect()
        end
    end
end

function this.ChangeMouseLookKeyPressState(lookState)
    if cachedPlatformKey ~= "pc" then
        return
    end

    if inputGate ~= nil then
        if lookState then
            inputGate:Set("MouseLook", inputGameplayType)
        else
            inputGate:Clear("MouseLook", inputGameplayType)
        end
    end

    isKeyPressForMouseLookState = lookState
end

-- 하드코딩...
function this.RefreshControlTargetsByUIFind()
    if uiService == nil then
        return
    end
    
    local controlButtonUI = uiService:FindByName("ControlButtonUI")
    local joyStickUI = uiService:FindByName("JoyStickUI")

    AddUniqueObject(this.AllControlTargetObjects, controlButtonUI)
    AddUniqueObject(this.AllControlTargetObjects, joyStickUI)

    AddUniqueObject(this.AlwaysDisableObjectsForPC, joyStickUI)

    local controlButtonUIScript = FindChildLuaScript(controlButtonUI, "ControlButtonUIScript")
    local joyStickScript = FindChildLuaScript(joyStickUI, "Script")

    AddUniqueObject(this.ControlledScriptObjectsForMobile, controlButtonUIScript)
    AddUniqueObject(this.ControlledScriptObjectsForMobile, joyStickScript)

    AddUniqueObject(this.ControlledScriptObjectsForConsole, controlButtonUIScript)
    AddUniqueObject(this.ControlledScriptObjectsForConsole, joyStickScript)

    AddUniqueObject(this.ControlledScriptObjectsForPC, controlButtonUIScript)    
end

function this.OnStart()
    script = this.scriptObject
    serviceApi = this.serviceApi    
    if serviceApi ~= nil then
        world = serviceApi.world
        uiService = serviceApi.uiService        
        platformService = serviceApi.platformService
        bubblyzService = serviceApi.bubblyzService
        if bubblyzService ~= nil then
            bubblyzService.OnPropertyChanged:AddListener(this.OnBubblyzOptionChanged)
        end
    end    

    cachedPlatformKey = GetPlatformKey()
    if script ~= nil then
        script:Log("platform key "..tostring(cachedPlatformKey))
    end

    local cameraService = serviceApi and serviceApi.cameraService or nil
    if cameraService ~= nil then
        camera = cameraService:FindCameraController(this.CameraName)
    end
    
    RebindInputRefsByPlatform()
    CacheInputGateChannels()
    CacheTouchEffectScript()
    CacheKeyGuideScripts()    
    CacheUILayoutModifiers()

    dirtyKeyGuideEnable = true
    this.RefreshBubblyzOptions()
    this.RefreshKeyGuideVisible()
    this.ApplyMouseCursorLock()

    this.RefreshControlTargetsByUIFind()
    this.ChangeMouseLookKeyPressState(false)
    this.ApplyCursorState()    
    this.RefreshPolicy()

    this.ApplyCameraControlMode()

    this.ApplyPlatformUILayout()
    this.ApplyCursorIcon()

    isStarted = true
    inputCameraType = VFramework.InputChannel.Camera    
end

function this.RefreshBubblyzOptions()
    if bubblyzService == nil then
        return
    end

    if cachedPlatformKey == nil then
        return
    end

    if cachedPlatformKey == "pc" then
        enableMouseCursorLock = bubblyzService.cursorConfineEnabled
        if bubblyzService.keyGuideEnabled ~= keyGuideEnable then
            dirtyKeyGuideEnable = true
            keyGuideEnable = bubblyzService.keyGuideEnabled
        end        
    else
        enableMouseCursorLock = false
        keyGuideEnable = false
        dirtyKeyGuideEnable = false
    end
end

function this.ApplyMouseCursorLock()
    if cachedPlatformKey ~= "pc" then
        return
    end

    cursor:SetConfined(enableMouseCursorLock)
end

function this.RefreshKeyGuideVisible()    
    if dirtyKeyGuideEnable == false then
        return
    end

    dirtyKeyGuideEnable = false
    
    for i, v in ipairs(keyGuideScripts) do        
        v.EnableHotKeyByPlatform(keyGuideEnable)
        if keyGuideEnable then
            v.Show()
        else
            v.Hide()
        end        
    end
end

function this.ApplyCameraControlMode()
    if camera == nil then
        return
    end

    if cachedPlatformKey == nil then
        return
    end    

    if cachedPlatformKey ~= "pc" then
        camera:SetMouseLookMode(VFramework.BackViewController.MouseLookMode.Drag)
        return
    end
    
    if IsCurrentMouseLookState() then
        --camera:SetMouseLookMode(VFramework.BackViewController.MouseLookMode.Drag)
        if inputCameraType ~= nil and inputGate ~= nil then
            inputGate:Set("MouseLook",inputCameraType)
        end
    else        
        if inputCameraType ~= nil and inputGate ~= nil then
            inputGate:Clear("MouseLook",inputCameraType)
        end        
        camera:SetMouseLookMode(VFramework.BackViewController.MouseLookMode.Always)
    end    
end

function this.OnUpdate(deltaTime)
    if isStarted == true and needApplyUiAfterStart == true then
        needApplyUiAfterStart = false
        this.ApplyByBlockState()
    end

    if camera == nil and cameraService ~= nil then
        camera = cameraService:FindCameraController(this.CameraName)
    end
end

function this.OnDestroy()
    if inputService ~= nil then
        inputService.OnButtonActionEvent:RemoveListener(this.OnButtonEvent)
    end
    inputGate = nil
    cursor = nil
    isStarted = false
    needApplyUiAfterStart = false
end

function this.OnApplicationFocus(focus)
    isApplicationFocus = focus
    this.ApplyCursorState()
    this.ApplyCameraControlMode()
end

function this.OnApplicationPause(paused)
    isApplicationPause = paused
    this.ApplyCursorState()
    this.ApplyCameraControlMode()
end

function this.ApplyPlatformUILayout()
    if cachedPlatformKey ~= "pc" then
        return
    end

    for i, v in ipairs(uiLayoutModifiers) do
        v.ApplyByPlatform(cachedPlatformKey)
    end
end

function this.ApplyCursorIcon()
    if this.CursorIcon2D == nil then
        return
    end

    if cachedPlatformKey ~= "pc" then
        return
    end

    if cursor == nil then
        return
    end

    cursor:SetIcon(this.CursorIcon2D, Vector2(0, 0))
end

__EX_FUNCTION__(this)
function this.RefreshPolicy()
    RebuildTrackedSets()
    RebuildPlatformDisableSet(cachedPlatformKey)
    RebuildScriptObjectsTable(cachedPlatformKey)
    this.ChangeTouchEffectState(true)
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnRoomStartMatch()
    if isStarted ~= true then
        needApplyUiAfterStart = true
        return
    end
    this.ApplyByBlockState()
end

-- Sequence_C.lua event listeners
__EX_FUNCTION__(this)
function this.OnStageInit()
    if isStarted ~= true then
        needApplyUiAfterStart = true
        return
    end
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnSpawnPlayer()
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnSetStage()
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnPlayerUI()
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnSpawnStartCraft()
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnStageStart()
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnStageFinished()
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnResult()
    this.ApplyByBlockState()
end

__EX_FUNCTION__(this)
function this.OnGameEnd()
    this.ApplyByBlockState()
end

function this.OnButtonEvent(actionName, buttonState)    
    if actionName ~= this.MouseLookKeyActionName then
        return
    end

    if IsButtonPressed(buttonState) then
        this.ChangeMouseLookKeyPressState(true)
        this.ApplyCursorState()
        this.ApplyCameraControlMode()
        return
    end

    if IsButtonReleased(buttonState) then
        this.ChangeMouseLookKeyPressState(false)
        this.ApplyCursorState()
        this.ApplyCameraControlMode()
        return
    end
end

function this.OnBubblyzOptionChanged(value)
    script:Log("option changed "..tostring(value))
    this.RefreshBubblyzOptions()
    this.RefreshKeyGuideVisible()
    this.ApplyMouseCursorLock()
end

function this.ChangeMouseLookModeUIOpenState(state)
    isOpenMouseLookModeUI = state
end

function this.ChangeTempHideControlUI(state)
    isTempHideControlUI = state
end

function this.ApplyBlockGamePlay(block, key)
    if cachedPlatformKey ~= "pc" then 
        return
    end

    if inputGate == nil then
        return
    end

    if block then
        inputGate:Set(key, inputGameplayType)
    else
        inputGate:Clear(key, inputGameplayType)
    end
end