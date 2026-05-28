local this = __CREATOR__.new()

this.TargetLocalPosition = __EX_VARIABLE__.vector3()
this.TargetLocalRotationEuler = __EX_VARIABLE__.vector3()
this.TargetLocalScale = __EX_VARIABLE__.vector3(1, 1, 1)
this.TargetSizeDelta = __EX_VARIABLE__.vector2()

local scriptObject = nil
local targetParentTransform = nil
local targetParentRectTransform = nil
local targetAnimator = nil

local hasCachedOrigin = false
local cachedOriginLocalPosition = nil
local cachedOriginLocalRotationEuler = nil
local cachedOriginLocalScale = nil
local cachedOriginSizeDelta = nil
local cachedOriginAnimatorEnabled = true
local hasSizeDelta = false
local hasApplyByPlatform = false

local function CopyVector3(value)
    if value == nil then
        return Vector3.zero
    end
    return Vector3(value.x, value.y, value.z)
end

local function GetTargetTransform()
    if scriptObject == nil then
        return nil
    end

    local owner = scriptObject.parent
    if owner == nil or owner.transform == nil then
        return nil
    end    

    return owner.transform
end

local function GetTargetRectTransform()    
    if VFramework == nil or VFramework.RectTransform == nil then
        return nil
    end

    --local ok, rectTransform = transform.vObject:CastByType(VFramework.RectTransform)
    local ok, rectTransform = scriptObject.parent:GetComponentByType(typeof(VFramework.RectTransform))    
    if ok == false then
        return nil
    end

    return rectTransform
end

local function CacheAnimatorComponent()
    targetAnimator = nil
    if targetParentTransform == nil or targetParentTransform.vObject == nil then
        return
    end
    if targetParentTransform.vObject.GetComponent == nil then
        return
    end
    targetAnimator = targetParentTransform.vObject:GetComponent("Animator")
end

local function SetAnimatorComponentEnabled(isEnabled)
    if targetAnimator == nil then
        return
    end
    targetAnimator.enabled = isEnabled
end

local function WriteSizeDelta(sizeDelta)
    if hasSizeDelta ~= true then
        return
    end

    targetParentRectTransform.sizeDelta = Vector2(sizeDelta.x, sizeDelta.y)
end

local function CacheOriginInternal()
    local resolved = GetTargetTransform()
    if resolved == nil then
        return false
    end

    targetParentTransform = resolved
    targetParentRectTransform = GetTargetRectTransform(targetParentTransform)
    CacheAnimatorComponent()

    cachedOriginLocalPosition = CopyVector3(resolved.localPosition)
    cachedOriginLocalScale = CopyVector3(resolved.localScale)

    local euler = resolved.localRotation.eulerAngles
    cachedOriginLocalRotationEuler = Vector3(euler.x, euler.y, euler.z)

    hasSizeDelta = targetParentRectTransform ~= nil
    if hasSizeDelta then
        local sizeDelta = targetParentRectTransform.sizeDelta
        cachedOriginSizeDelta = Vector2(sizeDelta.x, sizeDelta.y)
    else
        cachedOriginSizeDelta = Vector2.zero
    end

    if targetAnimator ~= nil then
        cachedOriginAnimatorEnabled = targetAnimator.enabled
    else
        cachedOriginAnimatorEnabled = true
    end

    hasCachedOrigin = true
    return true
end

function this.OnStart()
    scriptObject = this.scriptObject
    CacheOriginInternal()    

    if hasApplyByPlatform == true then
        hasApplyByPlatform = false
        this.ApplyByPlatformImpl()
    end
end


function this.ApplyByPlatform(platformKey)
    -- modify only pc platform
    if platformKey ~= "pc" then
        return
    end

    hasApplyByPlatform = true
    if this.ApplyByPlatformImpl() then
        hasApplyByPlatform = false
    end    
end

function this.ApplyByPlatformImpl()
    if hasCachedOrigin ~= true and CacheOriginInternal() ~= true then
        return false
    end

    if targetParentTransform == nil then
        return false
    end

    targetParentTransform.localPosition = CopyVector3(this.TargetLocalPosition)
    targetParentTransform.localScale = CopyVector3(this.TargetLocalScale)

    local targetEuler = this.TargetLocalRotationEuler
    targetParentTransform.localRotation = Quaternion.Euler(targetEuler.x, targetEuler.y, targetEuler.z)

    local targetSizeDelta = this.TargetSizeDelta
    if targetSizeDelta ~= nil then
        local absSizeX = Mathf.Abs(targetSizeDelta.x)
        local absSizeY = Mathf.Abs(targetSizeDelta.y)
        local nextSizeX = cachedOriginSizeDelta.x
        local nextSizeY = cachedOriginSizeDelta.y

        if absSizeX > Mathf.Epsilon then
            nextSizeX = absSizeX
        end

        if absSizeY > Mathf.Epsilon then
            nextSizeY = absSizeY
        end

        WriteSizeDelta(Vector2(nextSizeX, nextSizeY))
    end
    SetAnimatorComponentEnabled(false)
    return true
end

__EX_FUNCTION__(this)
function this.Restore()
    if hasCachedOrigin ~= true then
        return
    end

    if targetParentTransform == nil then
        return
    end

    targetParentTransform.localPosition = CopyVector3(cachedOriginLocalPosition)
    targetParentTransform.localScale = CopyVector3(cachedOriginLocalScale)
    targetParentTransform.localRotation = Quaternion.Euler(
        cachedOriginLocalRotationEuler.x,
        cachedOriginLocalRotationEuler.y,
        cachedOriginLocalRotationEuler.z
    )
    WriteSizeDelta(cachedOriginSizeDelta)
    SetAnimatorComponentEnabled(cachedOriginAnimatorEnabled)
end
