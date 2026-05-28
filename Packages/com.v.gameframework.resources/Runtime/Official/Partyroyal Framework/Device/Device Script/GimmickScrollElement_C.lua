local this = __CREATOR__.new()

local script

--local isMaterialCached = false
--local cachedMaterials = {}
--local cachedTilings = {}
--local cachedOffsets = {}
--local cachedRendererTransforms = {}
--local cachedBaseScales = {}

--this.EntryRenderers = __EX_VARIABLE__.list(__EX_VARIABLE__.component.renderer())
--this.UseScaleX = __EX_VARIABLE__.bool(false)
--this.UseScaleY = __EX_VARIABLE__.bool(false)
--this.UseScaleZ = __EX_VARIABLE__.bool(true)

local needHandlePendingData = false
local pendingShowState = false
local pendingPosition = nil
local boardCollider = nil

--[[local function CacheMaterialData()
    if isMaterialCached then return end
    if script == nil then return end
    if this.EntryRenderers == nil then return end

    for i = 1, #this.EntryRenderers do
        local renderer = this.EntryRenderers[i]
        if renderer ~= nil then
            local rendererTransform = renderer.transform
            local baseScale = nil
            if rendererTransform ~= nil then
                baseScale = rendererTransform.lossyScale
            end
            local materials = renderer.materials
            if materials ~= nil then
                for j = 1, #materials do
                    local material = materials[j]
                    if material ~= nil then
                        cachedMaterials[#cachedMaterials + 1] = material
                        cachedTilings[#cachedTilings + 1] = material.mainTextureScale
                        cachedOffsets[#cachedOffsets + 1] = material.mainTextureOffset
                        cachedRendererTransforms[#cachedRendererTransforms + 1] = rendererTransform
                        cachedBaseScales[#cachedBaseScales + 1] = baseScale
                    end
                end
            end
        end
    end

    isMaterialCached = true
end]]--

function this.OnStart()
    script = this.scriptObject
    if script == nil then return end
    --CacheMaterialData()

    if needHandlePendingData then
        script.parent:SetActive(pendingShowState)        
        needHandlePendingData = false
    else
        this.CachingCollider()
        
        -- loading중 생성 타이밍이 동일하지 않아 (서버에서 이미 생성/동작상태에서 나중에 클라에 일괄 동기화 생성되므로 로딩중 서버의 변경사항에 대한 활성화 상태 반영을 Collider의 enable여부로 판단하게 수정)
        local active = false
        if boardCollider ~= nil then
            active = boardCollider.enabled            
        end                

        if pendingPosition ~= nil then
            script.parent.transform.position = pendingPosition
        end
        script.parent:SetActive(active)
    end
end

function this.CachingCollider()
    if boardCollider ~= nil then
        return
    end

    local boardPath = "WorldTransform/Supports/Board"
    local target = script.parent:Find(boardPath)
    if target == nil then
        script:Log("Find failed: " ..boardPath)
        return
    end

    boardCollider = target:GetComponent("Collider")
    if boardCollider == nil then
        script:Log("Collider not found on: " ..boardPath)
    end
end

--[[function this.OnUpdate(deltaTime)
    if script == nil then return end
    if isMaterialCached == false then
        CacheMaterialData()
    end
    if cachedMaterials == nil or #cachedMaterials == 0 then return end
    if cachedRendererTransforms == nil or #cachedRendererTransforms == 0 then return end
    if cachedBaseScales == nil or #cachedBaseScales == 0 then return end
    if this.UseScaleX == false and this.UseScaleY == false and this.UseScaleZ == false then
        return
    end

    for i = 1, #cachedMaterials do
        local material = cachedMaterials[i]
        local rendererTransform = cachedRendererTransforms[i]
        local baseScale = cachedBaseScales[i]
        if material ~= nil and rendererTransform ~= nil and baseScale ~= nil then
            local currentScale = rendererTransform.lossyScale
            local baseScaleX = math.abs(baseScale.x)
            local baseScaleY = math.abs(baseScale.y)
            local baseScaleZ = math.abs(baseScale.z)

            local scaleX = math.abs(currentScale.x)
            local scaleY = math.abs(currentScale.y)
            local scaleZ = math.abs(currentScale.z)

            local tilingXFactor = 1.0
            local tilingYFactor = 1.0

            if this.UseScaleX then
                if scaleX > 0.0001 then
                    tilingXFactor = baseScaleX / scaleX
                end
            elseif this.UseScaleZ then
                if scaleZ > 0.0001 then
                    tilingXFactor = baseScaleZ / scaleZ
                end
            end

            if this.UseScaleY then
                if scaleY > 0.0001 then
                    tilingYFactor = baseScaleY / scaleY
                end
            elseif this.UseScaleZ then
                if scaleZ > 0.0001 then
                    tilingYFactor = baseScaleZ / scaleZ
                end
            end

            local baseTiling = cachedTilings[i]
            local baseOffset = cachedOffsets[i]
            if baseTiling ~= nil and baseOffset ~= nil then
                -- Preserve UV center while compensating scale with inverse tiling.
                local newTilingX = baseTiling.x * tilingXFactor
                local newTilingY = baseTiling.y * tilingYFactor

                local newOffsetX = baseOffset.x + (baseTiling.x - newTilingX) * 0.5
                local newOffsetY = baseOffset.y + (baseTiling.y - newTilingY) * 0.5

                material.mainTextureScale = Vector2(newTilingX, newTilingY)
                material.mainTextureOffset = Vector2(newOffsetX, newOffsetY)
            end
        end
    end
end]]--

__EX_FUNCTION__(this)
function this.OnHideEvent()    
    if script == nil then 
        needHandlePendingData = true
        pendingShowState = false        
        return 
    end
    
    script.parent:SetActive(false)
end

-- transform의 수치는 즉시 반영되지 않기 때문에 사이즈나 position에 대한 초기 동기화가 필요함. 현재는 스케일만 (추후에 수정되면 scale파라미터는 필요 없음.)
__EX_FUNCTION__(this)
function this.OnShowEvent()        
    if script == nil then 
        needHandlePendingData = true        
        pendingShowState = true
        return 
    end

    script.parent:SetActive(true)
end


__EX_FUNCTION__(this, __EX_VARIABLE__.vector3())
function this.OnShowAndPositionEvent(position)        
    if script == nil then 
        needHandlePendingData = true        
        pendingShowState = true
        pendingPosition = position
        return 
    end

    script.parent.transform.position = position
    script.parent:SetActive(true)
end