local this = __CREATOR__.new()

local serviceApi
local script
local world
local soundService
local playerService

this.JumpEffect = __EX_VARIABLE__.vobject()
this.JumpSound = __EX_VARIABLE__.asset.audioClip()

local EffectDestroyDelay = 3.0
local effectEntries = {}

function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject
    world = serviceApi.world
    soundService = serviceApi.soundService
    playerService = serviceApi.playerService
end

function this.OnUpdate(deltaTime)
    if effectEntries == nil or #effectEntries == 0 then return end

    for i = #effectEntries, 1, -1 do
        local entry = effectEntries[i]
        entry.timer = entry.timer - deltaTime
        if entry.timer <= 0 then
            if entry.effect ~= nil then
                entry.effect:Destroy()
            end
            table.remove(effectEntries, i)
        end
    end
end

local function PlayJumpEffect(pos, rot)
    if world == nil or script == nil or this.JumpEffect == nil then return end
    local effect = world:Instantiate(this.JumpEffect, pos, rot)
    table.insert(effectEntries, { effect = effect, timer = EffectDestroyDelay })
end

local function PlayJumpSound()
    if soundService == nil or this.JumpSound == nil then return end

    soundService:Play(this.JumpSound)
end

__EX_FUNCTION__(this, _VOBJECT_.vobject())
function this.OnJumpEvent(target)
    local localPlayer = playerService and playerService.localPlayer
    if localPlayer == nil or localPlayer.character == nil then return end
    if target ~= localPlayer.character then return end

    local characterTransform = localPlayer.character.transform
    PlayJumpEffect(characterTransform.position, characterTransform.rotation)
    PlayJumpSound()
end
