local this = __CREATOR__.new()

local serviceApi -- 프레임워크 서비스 API 캐시
local script -- 스크립트 컨텍스트 캐시
local world -- Instantiate API 캐시
local root -- 스크립트가 붙은 부모 트랜스폼
local rootCollider -- 루트 영역 BoxCollider
local rootBounds -- 루트 영역 bounds 캐시

this.AutoStart = __EX_VARIABLE__.bool(true)
this.ScrollObjects = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject()) -- 스크롤 대상 프리팹 목록
this.ScrollSpeed = __EX_VARIABLE__.float(1.0) -- 스크롤 속도
this.Padding = __EX_VARIABLE__.float(0.0) -- 오브젝트 간격
this.StartPoint = __EX_VARIABLE__.vobject() -- 초기 배치 기준점
this.UseCenterOnly = __EX_VARIABLE__.bool(false) -- 크기 무시, 중점 기준으로 배치/판정

local ExtraTailCount = 3 -- 시작점 밖 추가 배치 개수

local isPlaying = false -- Play/Stop 상태
local initialized = false -- 초기 구성 완료 여부
local autoPlayPending = false -- 초기 배치 완료 후 AutoStart 처리
local activeEntries = {} -- 활성 오브젝트 목록
local queueEntries = {} -- 대기 큐
local dictEntryScripts = {}

local scrollDirection = nil -- 실제 이동 방향
local reverseDirection = nil -- 배치 역방향
local rootStartValue = nil
local rootEndValue = nil
local createdCount = 0

local function GetEntryScript(entryobj)
    if entryobj == nil then return nil end
    return dictEntryScripts[entryobj]
end

function this.GetScrollDirection()
    return scrollDirection;
end
function this.GetScrollSpeed()
    return this.ScrollSpeed;
end
function this.GetScrollStartPos()
    return rootStartValue;
end
function this.GetScrollEndPos()
    return rootEndValue;
end

local function LogError(message)
    if script ~= nil then
        script:Log(message)
    end
end

local function LogInfo(message)
    if script ~= nil then
        script:Log(message)
    end
end

local function LogInitSummary(rootExtentValue)
    local rootLength = rootExtentValue * 2
    local directionText = string.format("(%s, %s, %s)", tostring(scrollDirection.x), tostring(scrollDirection.y), tostring(scrollDirection.z))
    local firstEntry = activeEntries[1]
    local firstEntryScript = dictEntryScripts[firstEntry]
    local firstPosText = "(nil)"
    --if firstEntry ~= nil and firstEntry.basePosition ~= nil then
    if firstEntryScript ~= nil then
        --local p = firstEntry.basePosition
        local p =  firstEntryScript.GetOriginPosition()
        firstPosText = string.format("(%s, %s, %s)", tostring(p.x), tostring(p.y), tostring(p.z))
    end

    local spacingTexts = {}
    for i = 2, #activeEntries do
        local prevEntry = activeEntries[i - 1]
        local entry = activeEntries[i]
        if prevEntry ~= nil and entry ~= nil then
            local prevEntryScript = dictEntryScripts[prevEntry]
            local entryScript = dictEntryScripts[entry] 
            --local delta = Vector3.Dot(prevEntry.basePosition - entry.basePosition, reverseDirection)
            local delta = Vector3.Dot(prevEntryScript.GetOriginPosition() - entryScript.GetOriginPosition(), reverseDirection)
            spacingTexts[#spacingTexts + 1] = tostring(delta)
        end
    end
    local spacingText = (#spacingTexts > 0) and table.concat(spacingTexts, ", ") or "(none)"

    LogInfo("Init summary.")
    LogInfo("Created=" .. tostring(createdCount) .. ", Active=" .. tostring(#activeEntries) .. ", Queue=" .. tostring(#queueEntries))
    LogInfo("RootLength=" .. tostring(rootLength) .. ", ScrollDirection=" .. directionText)
    LogInfo("FirstPosition=" .. firstPosText .. ", Spacing=" .. spacingText)
end

local function CopyVector3(vec)
    if vec == nil then
        return Vector3.zero
    end
    return Vector3(vec.x, vec.y, vec.z)
end

local function UpdateDirection()    
    scrollDirection = Vector3(0, 0, 1)
    reverseDirection = scrollDirection * -1.0
    --reverseDirection = Vector3(-scrollDirection.x, -scrollDirection.y, -scrollDirection.z)
end

local function GetProjectedExtent(bounds)
    local extents = bounds.extents
    return (math.abs(scrollDirection.x) * extents.x) + (math.abs(scrollDirection.y) * extents.y) + (math.abs(scrollDirection.z) * extents.z)
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

--[[local function GetEntryBoundsValues(entry)
    if entry == nil then return nil, nil end
    if rootStartValue == nil or rootEndValue == nil then return nil, nil end

    local objCenter = entry.basePosition
    if entry.center ~= nil then
        objCenter = objCenter + entry.center
    end

    local objExtent = entry.extent or 0
    local objMinValue = Vector3.Dot(objCenter, scrollDirection) - objExtent
    local objMaxValue = Vector3.Dot(objCenter, scrollDirection) + objExtent

    return objMinValue, objMaxValue
end]]--

local function SetRendererEnabled(entry, enabled)
    if entry == nil then return end
    if enabled == false then
        -- renderer enable되는 타이밍과 position 동기화가 안맞아서 그냥 멀리 날려버림.
        -- entry.object.transform.localPosition = Vector3(100000,100000,100000)
    end
    
    -- active/deactive 이후 position와 scale 동기화에 약 3프레임 이상의 차이가 있었다.
    -- entry.object:SetActive(enabled)        
    if entry.renderers ~= nil then
        for i = 1, #entry.renderers do
            if entry.renderers[i] ~= nil then
                entry.renderers[i].enabled = enabled
            end
        end
    end
end

--[[local function ResetEntryScale(entry)
    if entry == nil then return end
    if entry.baseScale == nil then
        entry.baseScale = CopyVector3(entry.object.transform.localScale)
    end
    entry.object.transform.localScale = CopyVector3(entry.baseScale)
end]]--

--[[local function UpdateEntryScale(entry)
    if entry == nil then return end
    if rootStartValue == nil or scrollDirection == nil or reverseDirection == nil then return end

    if entry.baseScale == nil then
        entry.baseScale = CopyVector3(entry.object.transform.localScale)
    end
    local basePosition = entry.basePosition
    local extent = entry.extent or 0
    if extent <= 0 then
        entry.object.transform.localPosition = basePosition
        ResetEntryScale(entry)
        return
    end

    local objCenter = basePosition
    if entry.center ~= nil then
        objCenter = objCenter + entry.center
    end

    local frontValue = Vector3.Dot(objCenter, scrollDirection) + extent
    local backValue = Vector3.Dot(objCenter, scrollDirection) - extent

    if frontValue > rootStartValue then
        local length = extent * 2
        local insideLength = rootStartValue - backValue
        local factor = 0
        if length > 0 then
            factor = insideLength / length
        end
        if factor < 0 then factor = 0 end
        if factor > 1 then factor = 1 end

        local shift = extent * (1 - factor)
        local adjustedPosition = basePosition + (reverseDirection * shift)

        local scale = CopyVector3(entry.baseScale)
        -- z축으로만 이동하도록 로직이 작성되었기 때문에 z에 관해서만 계산한다.
        scale.z = entry.baseScale.z * factor        

        entry.object.transform.localPosition = adjustedPosition
        entry.object.transform.localScale = scale
        return
    end

    if backValue < rootEndValue and frontValue > rootEndValue then
        local length = extent * 2
        local insideLength = frontValue - rootEndValue
        local factor = 0
        if length > 0 then
            factor = insideLength / length
        end
        if factor < 0 then factor = 0 end
        if factor > 1 then factor = 1 end

        local shift = extent * (1 - factor)
        local adjustedPosition = basePosition + (scrollDirection * shift)

        local scale = CopyVector3(entry.baseScale)
        -- z축으로만 이동하도록 로직이 작성되었기 때문에 z에 관해서만 계산한다.
        scale.z = entry.baseScale.z * factor

        entry.object.transform.localPosition = adjustedPosition
        entry.object.transform.localScale = scale
        return
    end

    entry.object.transform.localPosition = basePosition
    ResetEntryScale(entry)
end]]--

local function CreateElement(prefab)
    if world == nil or prefab == nil then return nil end

    local obj = world:Instantiate(prefab, Vector3.zero, Quaternion(0, 0, 0, 1))
    if obj == nil then return nil end
    
    local localRot = obj.transform.localRotation
    local localPos = obj.transform.localPosition
    local localScale = obj.transform.localScale

    obj:SetParent(root)
    
    obj.transform.localScale = localScale
    obj.transform.localRotation = localRot
    obj.transform.localPosition = localPos

    createdCount = createdCount + 1    

    --return obj
    --local elementScript = obj:GetLua()
    local elementScript = nil
    if obj ~= nil then
        local elementScriptObj = obj:Find("GimmickScrollElement_S")
        if elementScriptObj ~= nil then
            elementScript = elementScriptObj:GetLua()
        end
    end

    if elementScript ~= nil then
        elementScript.Caching()
    else
        local prefabName = (prefab ~= nil and prefab.name ~= nil) and prefab.name or "Unknown"
        LogError("Can`t find GimmickScrollElement_S script on scroll object. Skip create. Prefab="..tostring(prefabName))
        obj:Destroy()
    end

    return obj, elementScript
end

--[[local function CreateEntry(prefab)
    if world == nil or prefab == nil then return nil end

    local obj = world:Instantiate(prefab, Vector3.zero, Quaternion(0, 0, 0, 1))
    if obj == nil then return nil end

    obj:SetParent(root)
    createdCount = createdCount + 1

    local prefabName = (prefab ~= nil and prefab.name ~= nil) and prefab.name or "Unknown"
    local collider = obj:GetComponent("BoxCollider")
    local renderers = obj:GetComponentsInChildren("Renderer")
    local rigidbodies = obj:GetComponentsInChildren("Rigidbody")
    if collider == nil then
        LogError("BoxCollider missing on scroll object. Skip create. Prefab=" .. tostring(prefabName))
        obj:Destroy()
        return nil
    end    

    if rigidbodies ~= nil and #rigidbodies > 1 then
        LogError("Multiple Rigidbodies found on scroll object. Skip create. Prefab=" .. tostring(prefabName))
        obj:Destroy()
        return nil
    end

    local rigidbody = nil
    if rigidbodies ~= nil and #rigidbodies == 1 then
        rigidbody = rigidbodies[1]
    end

    local elementScript = obj:GetLua()
    if elementScript == nil then
        local elementScriptObj = obj:Find("GimmickScrollElement_S")
        if elementScriptObj ~= nil then
            elementScript = elementScriptObj:GetLua()
        end
    end

    local center = Vector3.zero
    local extent = 0
    local scale = obj.transform.localScale
    local rotation = obj.transform.localRotation
    center = GetCenterOffset(collider.center, scale, rotation)
    extent = GetProjectedExtentFromSize(collider.size, scale, rotation)

    local length = extent * 2
    local baseScale = CopyVector3(obj.transform.localScale)
    local basePosition = CopyVector3(obj.transform.localPosition)

    local entry = {
        object = obj,
        collider = collider,
        renderers = renderers,
        rigidbody = rigidbody,
        elementScript = elementScript,
        length = length,
        center = center,
        extent = extent,
        baseScale = baseScale,
        basePosition = basePosition,
        isInside = false,
        isOverlap = false,
        isOverlapEnter = false,
        isOverlapExit = false
    }

    SetRendererEnabled(entry, false)    
    return entry
end]]--


--[[local function RefreshEntryState(entry)
    if entry == nil then return end

    local isInside = true
    local isOverlapEnter = false
    local isOverlapExit = false

    local objMinValue, objMaxValue = GetEntryBoundsValues(entry)
    if objMinValue == nil then
        isInside = false
    else
        isInside = (objMaxValue >= rootEndValue) and (objMinValue <= rootStartValue)
        local fullyInside = (objMinValue >= rootEndValue) and (objMaxValue <= rootStartValue)
        isOverlapEnter = isInside and (not fullyInside)
            and (objMinValue < rootEndValue) and (objMaxValue > rootEndValue)
        isOverlapExit = isInside and (not fullyInside)
            and (objMaxValue > rootStartValue) and (objMinValue < rootStartValue)
    end

    entry.isInside = isInside
    entry.isOverlapEnter = isOverlapEnter
    entry.isOverlapExit = isOverlapExit
    entry.isOverlap = isOverlapEnter or isOverlapExit
end]]--

--[[local function ApplyEntryVisuals(entry, previousInside)
    if entry == nil then return end

    if entry.isOverlap then
        UpdateEntryScale(entry)    
    end

    if previousInside ~= entry.isInside then
        SetRendererEnabled(entry, entry.isInside)
    end
end]]--

local function Enqueue(entry, entryScript)
    if entry == nil then return end    
    
    --SetRendererEnabled(entry, false)
    --ResetEntryScale(entry)    
    entryScript.ResetEntryScale()
    table.insert(queueEntries, entry)
end

local function Dequeue()
    if #queueEntries == 0 then
        LogError("Queue is empty.")
        return nil
    end

    local entry = table.remove(queueEntries, 1)    
    local entryScript = dictEntryScripts[entry]
    entryScript.ApplyEntryMove()
    entryScript.ResetEntryScale()
    --entry.object.transform.localPosition = entry.basePosition
    --ResetEntryScale(entry)

    return entry
end

local function GetLastActiveEntry()
    local lastEntry = nil
    local lastValue = nil
    local entryScript = nil

    for i = 1, #activeEntries do
        entryScript = GetEntryScript(activeEntries[i])
        if entryScript ~= nil then            
            --local value = Vector3.Dot(entry.basePosition, scrollDirection)
            local value = Vector3.Dot(entryScript.GetOriginPosition(), scrollDirection)
            if lastValue == nil or value < lastValue then
                lastValue = value
                lastEntry = activeEntries[i]
            end
        end
    end

    return lastEntry
end

--[[local function PlaceEntry(entry, position)
    if entry == nil then return end

    entry.basePosition = CopyVector3(position)
    entry.object.transform.localPosition = entry.basePosition
    ResetEntryScale(entry)
end]]--

local function GetSpacing(prevEntryScript, nextEntryScript)
    if this.UseCenterOnly then
        return this.Padding
    end    
    
    local prevLength = prevEntryScript.GetBodyLength()
    local nextLength = nextEntryScript.GetBodyLength()
    return (prevLength * 0.5) + (nextLength * 0.5) + this.Padding
end

local function PrepareInitialObjects()
    if initialized then return end
    initialized = true

    if rootCollider == nil then
        LogError("Root BoxCollider missing.")
        return
    end
    if this.Padding <= 0.1 then
        LogError("Padding is too small. Initialization aborted.")
        return
    end
    if this.StartPoint == nil then
        LogError("StartPoint is nil.")
        return
    end
    if this.ScrollObjects == nil or #this.ScrollObjects == 0 then
        LogError("ScrollObjects is empty.")
        return
    end

    UpdateDirection()

    rootCollider.enabled = true
    local listCount = #this.ScrollObjects
    local rootCenterValue = Vector3.Dot(rootCollider.center, scrollDirection)
    local rootExtentValue = GetProjectedExtentFromSize(rootCollider.size, nil, nil)
    rootStartValue = rootCenterValue + rootExtentValue
    rootEndValue = rootCenterValue - rootExtentValue
    local scrollDistance = rootExtentValue * 2

    local paddingDistance = listCount * this.Padding
    local baseMultiplier = 1
    if paddingDistance > 0 then
        while (paddingDistance * baseMultiplier) < scrollDistance do
            baseMultiplier = baseMultiplier + 1
        end
    end
    local baseCount = listCount * baseMultiplier

    local extraMultiplier = 1
    while (listCount * extraMultiplier) <= ExtraTailCount do
        extraMultiplier = extraMultiplier + 1
    end
    local extraCount = listCount * extraMultiplier
    local totalCount = baseCount + extraCount

    for i = 1, totalCount do
        local prefabIndex = ((i - 1) % listCount) + 1
        --local entry = CreateEntry(this.ScrollObjects[prefabIndex])
        local entryObj, entryScript = CreateElement(this.ScrollObjects[prefabIndex])
        if entryObj ~= nil and entryScript ~= nil then
            dictEntryScripts[entryObj] = entryScript
            Enqueue(entryObj, entryScript)
        end
    end

    local startPos = this.StartPoint.transform.localPosition
    local lastEntryScript = nil
    local lastPos = startPos
    local lastInsideEntry = nil
    local placedCount = 0
    local entryScript = nil
    local entry = nil

    while placedCount < totalCount do        
        entry = Dequeue()
        entryScript = GetEntryScript(entry)
        if entryScript == nil then
            break
        end        

        local pos = startPos
        if lastEntryScript ~= nil then
            local spacing = GetSpacing(lastEntryScript, entryScript)
            pos = lastPos + (reverseDirection * spacing)
        end
        
        entryScript.Place(pos)  
        table.insert(activeEntries, entry)
              
        --PlaceEntry(entry, pos)        

        lastEntryScript = entryScript
        lastPos = pos

        --local previousInside = entry.isInside
        --RefreshEntryState(entry)
        --ApplyEntryVisuals(entry, previousInside)
        local previousInside = entryScript.GetIsInside()
        entryScript.RefreshEntryState()
        entryScript.ApplyEntryVisuals(previousInside)        

        if entry.isInside then
            lastInsideEntry = entry
        end

        placedCount = placedCount + 1
    end

    if lastInsideEntry == nil then
        LogError("StartPoint is outside Root BoxCollider.")
    end

    rootCollider.enabled = false
    
    LogInitSummary(rootExtentValue)
    if autoPlayPending then
        autoPlayPending = false
        this.Play()
    end
end

function this.OnStart()
    this.Caching()  
    PrepareInitialObjects()
end

function this.Caching()
    if script ~= nil then return end

    serviceApi = this.serviceApi
    script = this.scriptObject
    world = serviceApi.world

    root = script.parent
    rootCollider = root:GetComponent("BoxCollider")

    autoPlayPending = this.AutoStart
end

function this.OnFixedUpdate(deltaTime)
    if isPlaying == false then return end
    if rootCollider == nil then return end        

    local hasNewEntered = false    
    for entryObj, entryScript in pairs(dictEntryScripts) do
        local prevIsInside = entryScript.GetIsInside()
        entryScript.OnUpdateByRoot(deltaTime)
        if entryScript.GetIsInside() and (not prevIsInside) then
            hasNewEntered = true
        end
    end

    --if #activeEntries == 0 then return end   

    local frontIndex = nil
    local frontEntry = nil
    local frontValue = nil
    local entryEntered = false
    --local moveDelta = scrollDirection * (this.ScrollSpeed * deltaTime)

    for i = 1, #activeEntries do
        local entry = activeEntries[i]
        if entry ~= nil then
            local entryScript = dictEntryScripts[entry]
            if entryScript ~= nil then
                --entryScript.OnUpdateByRoot(deltaTime)
                --entryEntered = entryScript.GetIsInside()

                --local objCenter = entry.basePosition
                --if entry.center ~= nil then
                --    objCenter = objCenter + entry.center
                --end

                local objCenter = entryScript.GetCurrentCenter()                
                local objFrontValue = Vector3.Dot(objCenter, scrollDirection) + (entry.extent or 0)
                if frontValue == nil or objFrontValue > frontValue then
                    frontValue = objFrontValue
                    frontEntry = entry
                    frontIndex = i
                end
            end            
        end
    end

    --if frontEntry ~= nil and frontEntry.isInside == false then
    if frontEntry ~= nil then
        local frontEntryScript = dictEntryScripts[frontEntry]
        if frontEntryScript ~= nil and frontEntryScript.GetIsInside() == false and frontEntryScript.GetIsApproaching() == false then
            frontEntryScript.Stop()
            table.remove(activeEntries, frontIndex)        
            Enqueue(frontEntry, frontEntryScript)
        end
    end

    if hasNewEntered then
        local newEntry = Dequeue()
        if newEntry == nil then
            LogError("Queue is empty. Runtime creation is disabled.")
        end
        if newEntry ~= nil then
            local lastActiveScript = GetEntryScript(GetLastActiveEntry())
            local baseEntryScript = nil
            if activeEntries[1] ~= nil then
                baseEntryScript = GetEntryScript(activeEntries[1])            
            end
            --local placePos = (baseEntry ~= nil and baseEntry.object ~= nil)                and baseEntry.basePosition                or this.StartPoint.transform.localPosition
            local placePos = baseEntryScript.GetOriginPosition()
            if lastActiveScript ~= nil then
                local spacing = GetSpacing(lastActiveScript, newEntry)
                --placePos = lastActive.basePosition + (reverseDirection * spacing)
                placePos = lastActiveScript.GetOriginPosition() + (reverseDirection * spacing)
            elseif baseEntryScript ~= nil then
                local spacing = GetSpacing(baseEntryScript, newEntry)
                --placePos = baseEntry.basePosition + (reverseDirection * spacing)
                placePos = baseEntryScript.GetOriginPosition() + (reverseDirection * spacing)
            end

            local newEntryScript = GetEntryScript(newEntry)
            if newEntryScript ~= nil then
                newEntryScript.Play()
                newEntryScript.Place(placePos)
                local previousInside = newEntryScript.GetIsInside()
                newEntryScript.RefreshEntryState()
                newEntryScript.ApplyEntryVisuals(previousInside)                
            end

            table.insert(activeEntries, newEntry)
            
            --PlaceEntry(newEntry, placePos)
            --local previousInside = newEntry.isInside
            --RefreshEntryState(newEntry)
            --ApplyEntryVisuals(newEntry, previousInside)
            --table.insert(activeEntries, newEntry)
        end
    end
end

__EX_FUNCTION__(this)
function this.Play()
    if initialized == false then
        PrepareInitialObjects()
    end
    if this.Padding <= 0.1 then
        LogError("Padding is too small. Play aborted.")
        return
    end
    if rootCollider == nil then
        LogError("Play aborted. Root BoxCollider missing.")
        return
    end

    isPlaying = true

    for k,v in pairs(dictEntryScripts) do        
        v.Play()
    end
end

__EX_FUNCTION__(this)
function this.Stop()
    isPlaying = false
end
