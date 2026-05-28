local this = __CREATOR__.new()

local serviceApi
local script
local soundService

this.StartSound = __EX_VARIABLE__.asset.audioClip()

function this.OnStart()

    serviceApi = this.serviceApi
    script = this.scriptObject
    soundService = serviceApi.soundService

end

__EX_FUNCTION__(this)
function this.OnStartEvent()

    if this.StartSound ~= nil and soundService ~= nil and script ~= nil and script.parent ~= nil then        
        soundService:PlayAtPosition(this.StartSound, script.parent.transform.position)        
    end

end
