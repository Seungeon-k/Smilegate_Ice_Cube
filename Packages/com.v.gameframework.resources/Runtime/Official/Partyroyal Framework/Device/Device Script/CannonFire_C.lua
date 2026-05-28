local this = __CREATOR__.new()

local serviceApi
local scriptObject
local sfxSource = nil
local VFX_CannonFire = nil
local VFX_CannonBoom = nil

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
    
    local parent = scriptObject.parent.parent
    if parent == nil then        
        return
    end

    local sfxObj = parent:Find("SFX")
    if sfxObj ~= nil then
        sfxSource = sfxObj:GetComponent("AudioSource")
        if sfxSource ~= nil then
            sfxSource.loop = false            
        end
    end    
    
    local vfxParent = parent:Find("Party_Cannon/FireOrigin")
    if vfxParent ~= nil then
        VFX_CannonFire = vfxParent:Find("VFX_CannonFire"):GetComponent("ParticleSystem")
        VFX_CannonBoom = vfxParent:Find("VFX_CannonBoom"):GetComponent("ParticleSystem")            
    end    
end

__EX_FUNCTION__(this)
function this.FireEffect()
    -- 🎵 SFX 재생
    if sfxSource ~= nil and sfxSource.vObject.activeSelf then
        sfxSource:Play()
    end

    if VFX_CannonFire ~= nil then
        VFX_CannonFire:Stop(true)
        VFX_CannonFire:Play(true)
    end

    if VFX_CannonBoom ~= nil then
        VFX_CannonBoom:Stop(true)
        VFX_CannonBoom:Play(true)
    end      
end
