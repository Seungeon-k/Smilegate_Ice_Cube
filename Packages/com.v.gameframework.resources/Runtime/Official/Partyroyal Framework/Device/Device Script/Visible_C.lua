local this = __CREATOR__.new()

this.UseSharedMaterial = __EX_VARIABLE__.bool(false)

local scriptObject
local root = nil
local renderers = {} 

local Visible_S

local dissolveValue = 1.0
local dissolveTarget = 1.0
local isDissolving = false

function this.OnAwake()
    scriptObject = this.scriptObject
    root = scriptObject.parent.parent    
    
    local visibleVObj = scriptObject.parent:Find("Visible_S")
        if visibleVObj then
            Visible_S = visibleVObj:GetLua()
        end
        
        renderers = root:GetComponentsInChildren("Renderer")
        
        if Visible_S then
            dissolveValue = 1.0
            dissolveTarget = 1.0    
        end
        
        this.UpdateAllMaterials(dissolveValue)    
end

function this.OnStart()
    if not Visible_S then return end
    if Visible_S.CurrentVisible == true and dissolveValue >= 1.0 and not isDissolving then
        dissolveValue = 0.0
        dissolveTarget = 0.0
        isDissolving = false
        this.UpdateAllMaterials(dissolveValue)
        scriptObject:Log("Late Join Sync: Instant Visible")
    else
        this.UpdateAllMaterials(1)
    end
end

function this.OnUpdate(deltaTime)
    if not isDissolving or not Visible_S then return end
    
    local totalDuration = Visible_S.Duration
    if totalDuration <= 0 then totalDuration = 0.1 end 

    local step = (1.0 / totalDuration) * deltaTime
    local diff = dissolveTarget - dissolveValue

    if math.abs(diff) <= step then
        dissolveValue = dissolveTarget
        isDissolving = false       
    else        
        dissolveValue = dissolveValue + (diff > 0 and step or -step)
    end

    this.UpdateAllMaterials(dissolveValue)
end

local function getMaterials(renderer)
    if this.UseSharedMaterial then
        return renderer.sharedMaterials
    else
        return renderer.materials
    end
end

function this.UpdateAllMaterials(value)
    if renderers == nil then return end    

    for i = 1, #renderers do
        local renderer = renderers[i]

        local mats = getMaterials(renderer)
        if mats then
            for j = 1, #mats do
                local mat = mats[j]
                if mat then
                    mat:SetFloat("_Dissolve", value)
                end
            end
        end
    end
end

__EX_FUNCTION__(this)
function this.Show()    
    dissolveTarget = 0.0
    isDissolving = true
end

__EX_FUNCTION__(this)
function this.Hide()    
    dissolveTarget = 1.0
    isDissolving = true
end