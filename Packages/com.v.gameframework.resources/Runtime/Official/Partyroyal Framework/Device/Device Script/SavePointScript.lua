local this = __CREATOR__.new()

this.SpawnPoint = _VOBJECT_.playerSpawnPoint()

this.OnSavePointEntered = __EX_VARIABLE__.event()
this.OnPlayerEnteredSavepoint = __EX_VARIABLE__.event(_VOBJECT_.player())

local serviceApi

function this.OnAwake()    
    serviceApi = this.serviceApi
end

function this.OnTriggerEnter(collider)
    local _, character = collider.vObject:CastByType(typeof(VFramework.Character))
    if character == nil then
        return
    end

    character.player.savePlayerSpawnPoint = this.SpawnPoint

    this.OnSavePointEntered:Call()
    this.OnPlayerEnteredSavepoint:Call(character.player)
end