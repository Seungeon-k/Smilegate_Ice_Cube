local this = __CREATOR__.new()

local script = nil
local bodyObject = nil
local bodyCollider = nil
local bodyCenter = nil
local bodyExtent = 0
local bodyLength = 0
local scaleTargetTransforms = {}
local scaleTargetOriginScales = {}
local scaleTargetObjectLocalPositions = {}
local scaleTargetColliders = {}
local rigidBody = nil

function this.GetBodyLength()
    return bodyLength
end
local originScale = nil
local originPosition = nil
local worldObjectPosition = nil
-- Overlap shift keeps scale target aligned with clipping.
local overlapShift = nil
function this.GetOriginPosition()
    return originPosition
end

function this.GetCurrentCenter()
    return originPosition + bodyCenter
end

local isInside = false
function this.GetIsInside()
    return isInside
end
local isApproaching = false
function this.GetIsApproaching()
    return isApproaching
end
local isOverlap = false
local isOverlapEnter = false
local isOverlapExit = false
local isPlaying = false
local scrollSpeed = 1
local scrollDirection = nil
local reverseDirection = nil
local gimmickRootScript = nil
local rootStart = 0
local rootEnd = 0
-- MovePostion에 의해서 이동 처리를 할때 queueing을 시켜놓고 먼거리에 있던 오브젝트를 활성화시키면서 이동시키면 엄청난 Force가 캐릭터에 영향을 줄수 있으므로
-- 위치이동이 된 이후에 활성화가 되도록 일시적으로 딜레이를 처리한다.
local pendingActive = true
--local PendingActiveDuration = 0.1
local PENDING_ACTIVE_DURATION = 0.1
local pendingActiveRemainTime = 0.0

this.ScaleTargetObjects = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())
this.OnShowEvent = __EX_VARIABLE__.event()
this.OnHideEvent = __EX_VARIABLE__.event()
this.OnShowAndPositionEvent = __EX_VARIABLE__.event(__EX_VARIABLE__.vector3())

local function CopyVector3(vec)
    if vec == nil then
        return Vector3.zero
    end
    return Vector3(vec.x, vec.y, vec.z)
end

local function GetCenterOffset(center, scale, rotation)
    local offset = center
    if scale ~= nil then
        offset = Vector3(center.x * scale.x, center.y * scale.y, center.z * scale.z)
    end
    if rotation ~= nil then
        offset = rotation * offset
    end
    return offset
end


local function GetProjectedExtentFromSize(size, scale, rotation)
    local sx = size.x
    local sy = size.y
    local sz = size.z
    if scale ~= nil then
        sx = sx * math.abs(scale.x)
        sy = sy * math.abs(scale.y)
        sz = sz * math.abs(scale.z)
    end

    local halfSize = Vector3(sx * 0.5, sy * 0.5, sz * 0.5)
    if rotation == nil then
        return (math.abs(scrollDirection.x) * halfSize.x) + (math.abs(scrollDirection.y) * halfSize.y) + (math.abs(scrollDirection.z) * halfSize.z)
    end

    local right = rotation * Vector3(1, 0, 0)
    local up = rotation * Vector3(0, 1, 0)
    local forward = rotation * Vector3(0, 0, 1)

    local absRight = Vector3(math.abs(right.x), math.abs(right.y), math.abs(right.z))
    local absUp = Vector3(math.abs(up.x), math.abs(up.y), math.abs(up.z))
    local absForward = Vector3(math.abs(forward.x), math.abs(forward.y), math.abs(forward.z))

    local aabbExtents = Vector3(
        absRight.x * halfSize.x + absUp.x * halfSize.y + absForward.x * halfSize.z,
        absRight.y * halfSize.x + absUp.y * halfSize.y + absForward.y * halfSize.z,
        absRight.z * halfSize.x + absUp.z * halfSize.y + absForward.z * halfSize.z
    )

    return (math.abs(scrollDirection.x) * aabbExtents.x) + (math.abs(scrollDirection.y) * aabbExtents.y) + (math.abs(scrollDirection.z) * aabbExtents.z)
end

local function ApplyScaleTargetPosition(offset)
    if scaleTargetTransforms == nil then return end
    for i = 1, #scaleTargetTransforms do
        local transform = scaleTargetTransforms[i]
        local basePosition = scaleTargetObjectLocalPositions[i]
        if transform ~= nil and basePosition ~= nil then
            transform.localPosition = basePosition + offset
        end
    end
end

-- Scale target objects to match clipped length.
local function ApplyScaleTargetScale(factor)
    if scaleTargetTransforms == nil then return end
    for i = 1, #scaleTargetTransforms do
        local transform = scaleTargetTransforms[i]
        if transform ~= nil then
            local originScale = scaleTargetOriginScales[i]
            if originScale == nil then
                originScale = CopyVector3(transform.localScale)
                scaleTargetOriginScales[i] = originScale
            end
            local scale = CopyVector3(originScale)
            scale.z = originScale.z * factor
            transform.localScale = scale
        end
    end
end

local function GetPrimaryScaleTargetScale()
    if scaleTargetTransforms == nil then return nil end
    for i = 1, #scaleTargetTransforms do
        local transform = scaleTargetTransforms[i]
        if transform ~= nil then
            return transform.localScale
        end
    end
    return nil
end

local function SetScaleTargetScaleZero()
    if scaleTargetTransforms == nil then return end
    for i = 1, #scaleTargetTransforms do
        local transform = scaleTargetTransforms[i]
        if transform ~= nil then
            transform.localScale = Vector3.zero
        end
    end
end

local function SetScaleTargetCollidersEnabled(enabled)
    if scaleTargetColliders == nil then return end
    for i = 1, #scaleTargetColliders do
        local collider = scaleTargetColliders[i]
        if collider ~= nil then
            collider.enabled = enabled
        end
    end
end

function this.ResetEntryScale()
    if bodyObject == nil then return end
    if originScale == nil then
        originScale = CopyVector3(bodyObject.transform.localScale)
    end
    bodyObject.transform.localScale = CopyVector3(originScale)
    ApplyScaleTargetPosition(Vector3.zero)
    ApplyScaleTargetScale(1)
    overlapShift = Vector3.zero
end

local function Reset()        

    isInside = false
    isApproaching = false
    isOverlap = false
    isOverlapEnter = false
    isOverlapExit = false    
end

function this.OnStart()    
    overlapShift = Vector3.zero
end

local isCaching = false
-- Cache references and precompute bounds used for overlap checks.
function this.Caching()
    if isCaching then return end

    script = this.scriptObject

    if script ~= nil then
        bodyObject = script.parent
        bodyCollider = bodyObject:GetComponent("BoxCollider")        
    end

    if gimmickRootScript == nil then
        local root = script.parent.parent
        local gimmickRootScriptVObj = root:Find("GimmickScroll_S")
        gimmickRootScript = gimmickRootScriptVObj:GetLua()        
    end    

    if isCaching == false then
        scrollDirection = gimmickRootScript.GetScrollDirection()
        reverseDirection = scrollDirection * -1.0
        scrollSpeed = gimmickRootScript.GetScrollSpeed()
        rootStart = gimmickRootScript.GetScrollStartPos()
        rootEnd = gimmickRootScript.GetScrollEndPos()    

        local scale = bodyObject.transform.localScale
        local rotation = bodyObject.transform.localRotation
        bodyCenter = GetCenterOffset(bodyCollider.center, scale, rotation)
        bodyExtent = GetProjectedExtentFromSize(bodyCollider.size, scale, rotation)

        bodyLength = bodyExtent * 2
        originScale = CopyVector3(scale)
        originPosition = CopyVector3(bodyObject.transform.localPosition)
        rigidBody = bodyObject:GetComponent("Rigidbody")            
        if rigidBody ~= nil then
            worldObjectPosition = CopyVector3(rigidBody.position)
        end

        scaleTargetTransforms = {}
        scaleTargetOriginScales = {}
        scaleTargetObjectLocalPositions = {}
        scaleTargetColliders = {}
        if this.ScaleTargetObjects ~= nil then
            for i = 1, #this.ScaleTargetObjects do
                local targetObject = this.ScaleTargetObjects[i]
                if targetObject ~= nil then
                    local targetTransform = targetObject.transform
                    if targetTransform ~= nil then
                        scaleTargetTransforms[#scaleTargetTransforms + 1] = targetTransform
                        scaleTargetObjectLocalPositions[#scaleTargetObjectLocalPositions + 1] = CopyVector3(targetTransform.localPosition)
                        scaleTargetOriginScales[#scaleTargetOriginScales + 1] = CopyVector3(targetTransform.localScale)
                    end
                    local targetColliders = targetObject:GetComponentsInChildren("Collider")
                    if targetColliders ~= nil then
                        for j = 1, #targetColliders do
                            scaleTargetColliders[#scaleTargetColliders + 1] = targetColliders[j]
                        end
                    end
                end
            end
        end

        bodyCollider.enabled = false

        SetScaleTargetCollidersEnabled(false)
        this.RefreshEntryState()
    end

    isCaching = true
end

function this.Play()
    this.Caching() 

    if gimmickRootScript == nil then return end    

    isPlaying = true
    Reset()
end

function this.Place(pos)
    originPosition = CopyVector3(pos)
    bodyObject.transform.localPosition = originPosition
    this.ResetEntryScale()
end


function this.GetEntryBoundsValues()    
    local objCenter = originPosition
    if bodyCenter ~= nil then
        objCenter = objCenter + bodyCenter
    end

    local objExtent = bodyExtent or 0
    local objMinValue = Vector3.Dot(objCenter, scrollDirection) - objExtent
    local objMaxValue = Vector3.Dot(objCenter, scrollDirection) + objExtent

    return objMinValue, objMaxValue
end

function this.SetRendererEnabled(enabled)
    if bodyObject == nil then return end
    -- active/deactive has 3+ frame delay for position/scale sync.    
    if this.EntryRenderers ~= nil then
        for i = 1, #this.EntryRenderers do
            if this.EntryRenderers[i] ~= nil then
                this.EntryRenderers[i].enabled = enabled
            end
        end
    end
end

-- Adjust local scale/position when entry overlaps root bounds.
function this.UpdateEntryScale()
    if bodyObject == nil then return end    

    if originScale == nil then
        originScale = CopyVector3(bodyObject.transform.localScale)
    end
    local basePosition = originPosition
    local extent = bodyExtent or 0
    if extent <= 0 then
        bodyObject.transform.localPosition = basePosition
        this.ResetEntryScale()
        return
    end

    local objCenter = basePosition
    if bodyCenter ~= nil then
        objCenter = objCenter + bodyCenter
    end

    local frontValue = Vector3.Dot(objCenter, scrollDirection) + extent
    local backValue = Vector3.Dot(objCenter, scrollDirection) - extent

    if frontValue > rootStart then
        local length = extent * 2
        local insideLength = rootStart - backValue
        local factor = 0
        if length > 0 then
            factor = insideLength / length
        end
        if factor < 0 then factor = 0 end
        if factor > 1 then factor = 1 end

        local shift = extent * (1 - factor)
        overlapShift = reverseDirection * shift
        ApplyScaleTargetPosition(overlapShift)
        ApplyScaleTargetScale(factor)
        return
    end

    if backValue < rootEnd and frontValue > rootEnd then
        local length = extent * 2
        local insideLength = frontValue - rootEnd
        local factor = 0
        if length > 0 then
            factor = insideLength / length
        end
        if factor < 0 then factor = 0 end
        if factor > 1 then factor = 1 end

        local shift = extent * (1 - factor)
        overlapShift = scrollDirection * shift
        ApplyScaleTargetPosition(overlapShift)
        ApplyScaleTargetScale(factor)
        return
    end

    this.ResetEntryScale()
end

-- Compute inside/overlap flags from projected bounds.
function this.RefreshEntryState()
    local nextInside = true
    local nextApproaching = false
    local nextOverlapEnter = false
    local nextOverlapExit = false

    local objMinValue, objMaxValue = this.GetEntryBoundsValues()
    if objMinValue == nil then
        nextInside = false
    else
        nextInside = (objMaxValue >= rootEnd) and (objMinValue <= rootStart)
        local fullyInside = (objMinValue >= rootEnd) and (objMaxValue <= rootStart)
        nextOverlapEnter = nextInside and (not fullyInside)
            and (objMinValue < rootEnd) and (objMaxValue > rootEnd)
        nextOverlapExit = nextInside and (not fullyInside)
            and (objMaxValue > rootStart) and (objMinValue < rootStart)

        if nextInside == false then
            local speed = scrollSpeed or 0
            if speed > 0 then
                nextApproaching = (objMaxValue < rootEnd)
            elseif speed < 0 then
                nextApproaching = (objMinValue > rootStart)
            end
        end
    end

    isInside = nextInside
    isApproaching = nextApproaching
    isOverlapEnter = nextOverlapEnter
    isOverlapExit = nextOverlapExit
    isOverlap = nextOverlapEnter or nextOverlapExit
end

-- Apply scale and renderer visibility based on current state.
function this.ApplyEntryVisuals(previousInside)
    if isOverlap then
        this.UpdateEntryScale()
    elseif isInside then
        this.ResetEntryScale()
    else
        SetScaleTargetScaleZero()
        overlapShift = Vector3.zero
    end

    if previousInside ~= isInside then
        this.SetRendererEnabled(isInside)
    end
end

-- Update cached local positions; ApplyEntryMove will push them to transforms.
function this.UpdateEntryMove(moveDelta)
    if moveDelta == nil then return end    
    originPosition = originPosition + moveDelta           
    
end

-- Apply movement; MovePosition is used when rigidbody exists.
function this.ApplyEntryMove(syncTransformPosition)
    if bodyObject == nil then return end

    if rigidBody ~= nil then
        if bodyObject.parent ~= nil and bodyObject.parent.transform ~= nil then
            worldObjectPosition = bodyObject.parent.transform:TransformPoint(originPosition)
        else
            worldObjectPosition = originPosition
        end
        rigidBody:MovePosition(worldObjectPosition)
        if syncTransformPosition then
            bodyObject.transform.position = worldObjectPosition
        end
    else
        bodyObject.transform.localPosition = originPosition
    end

    if isOverlap then
        ApplyScaleTargetPosition(overlapShift)
    else
        ApplyScaleTargetPosition(Vector3.zero)
    end
end

-- Root-driven update to move, clip, and raise show/hide events.
function this.OnUpdateByRoot(deltaTime)
    
    if isPlaying == false then return end    
    if scrollDirection == nil then return end

    local previousInside = isInside
    this.RefreshEntryState()
    if isInside == false and isOverlap == false and isApproaching == false then
        return
    end

    local moveDelta = scrollDirection * (scrollSpeed * deltaTime)
    this.UpdateEntryMove(moveDelta)

    this.RefreshEntryState()
    this.ApplyEntryVisuals(previousInside)

    -- 숨김처리를 할때는 숨김프로세스를 수행하면서 위치가 일시적으로 변경되면서 큰 Force값이 캐릭터에 영향을 줄 수 있으므로 사전에 계산된상태값을 기반으로 미리 충돌체 비활성처리를 한다.
    if previousInside ~= isInside then
        if isInside == false then
            SetScaleTargetCollidersEnabled(false)
            this.OnHideEvent:Call()
        end
    end

    if pendingActive then
        pendingActiveRemainTime = pendingActiveRemainTime - deltaTime
        if pendingActiveRemainTime <= 0.0 then
            pendingActive = false
            pendingActiveRemainTime = 0.0
            if isInside == false then
                SetScaleTargetCollidersEnabled(false)
                this.OnHideEvent:Call()
            else
                SetScaleTargetCollidersEnabled(true)
                if rigidBody ~= nil then
                    this.OnShowAndPositionEvent:Call(bodyObject.transform.position)
                else
                    this.OnShowAndPositionEvent:Call(bodyObject.transform.localPosition)
                end                
                --this.OnShowEvent:Call()
            end                        
        end
    end

    local enteredInside = (previousInside == false and isInside == true)
    this.ApplyEntryMove(previousInside ~= isInside)

    if previousInside ~= isInside then
        if isInside then                        
            if scaleTargetTransforms ~= nil and #scaleTargetTransforms > 0 then
                for i = 1, #scaleTargetTransforms do
                    local transform = scaleTargetTransforms[i]
                    if transform ~= nil then
                        transform:SyncTransform()
                    end
                end                
            end            
            pendingActive = true
            pendingActiveRemainTime = PENDING_ACTIVE_DURATION
        end
    end
end

function this.Stop()
    isPlaying = false
end