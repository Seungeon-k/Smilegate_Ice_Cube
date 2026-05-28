local this = __CREATOR__.new()

local serviceApi
local script
local world
local renderers
local soundService

this.HitEffect = __EX_VARIABLE__.vobject()
this.HitSound = __EX_VARIABLE__.asset.audioClip()
this.DestroyEffect = __EX_VARIABLE__.vobject()

local EffectDestroyDelay = 3.0
local destroyEff = nil
local hitEff = nil
local destroyDelayTimer = 0
local isDestroyDelayActive = false
local isCached = false

function this.OnStart()    
    this.Caching()
end

function this.Caching()
    if isCached == true then
        return
    end

    isCached = true
    serviceApi = this.serviceApi
    script = this.scriptObject
    world = serviceApi.world
    soundService = serviceApi.soundService

    renderers = script.parent:GetComponentsInChildren("Renderer")
    if renderers == nil or #renderers == 0 then
        script:Log("[PopBouncerClient] renderer is nil")
    end

end

function this.OnUpdate(deltaTime)

    if isDestroyDelayActive == false then return end

    destroyDelayTimer = destroyDelayTimer - deltaTime
    if destroyDelayTimer <= 0 then
        if destroyEff ~= nil then
            destroyEff:Destroy()
            destroyEff = nil
        end

        if hitEff ~= nil then
            hitEff:Destroy()
            destroyEff = nil
        end        
        isDestroyDelayActive = false
    end

end


function this.DestroySelf()

    this.HideMeshRenderer()
    this.CreateDestroyEffect()
    --script.parent:Destroy()

end


function this.HideMeshRenderer()

    this.Caching()
    if renderers == nil then
        script:Log("[PopBouncerClient] renderer is nil")
        return
    end

    for i = 1, #renderers do
        local renderer = renderers[i]
        if renderer ~= nil then
            renderer.enabled = false
        end
    end

end


function this.CreateDestroyEffect()

    if this.DestroyEffect == nil then return end

    this.Caching()
    if script == nil then return end

    local parent = script.parent
    local pos = parent.transform.position
    local rot = parent.transform.rotation

    destroyEff = world:Instantiate(this.DestroyEffect, pos, rot)
    destroyDelayTimer = EffectDestroyDelay
    isDestroyDelayActive = true

end

function this.CreateHitEffect()

    if this.HitEffect == nil then return end
    this.Caching()
    if script == nil then return end

    local parent = script.parent
    local pos = parent.transform.position
    local rot = parent.transform.rotation

    hitEff = world:Instantiate(this.HitEffect, pos, rot)
end

__EX_FUNCTION__(this, _VOBJECT_.vobject())
function this.OnDestroyEvent(target)

    if script == nil then
        this.Caching()
    end

    if target ~= nil then
        if this.HitSound ~= nil and soundService ~= nil then        
            soundService:Play(this.HitSound)
        end

        this.CreateHitEffect()
    end
    this.DestroySelf()

end
