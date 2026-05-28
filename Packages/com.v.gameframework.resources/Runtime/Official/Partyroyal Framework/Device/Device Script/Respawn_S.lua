local this = __CREATOR__.new()

local serviceApi
local script

this.StartSpawnPoint = __EX_VARIABLE__.bool(false)      
this.LastSpawnPoint = __EX_VARIABLE__.bool(false)       
this.ReferencedSpawner = __EX_VARIABLE__.bool(false)    
this.SpawnerRef = __EX_VARIABLE__.vobject.playerSpawnPoint()
this.SavePointPriority = __EX_VARIABLE__.bool(false)
this.RespawnDelay = __EX_VARIABLE__.float(0.5)            
this.OnPlayerCollided =  __EX_VARIABLE__.event(__EX_VARIABLE__.vobject.player())

function this.OnAwake()    
    serviceApi = this.serviceApi        
    script = this.scriptObject                            
end    

local function RespawnSequenceAsync(player)
    if this.RespawnDelay > 0 then        
        VFramework.WaitForSeconds(this.RespawnDelay)
    end

    if not player or not player.character then return end

    local targetSpawnPoint = nil
    
    if this.SavePointPriority and player.savePlayerSpawnPoint ~= nil then
        targetSpawnPoint = player.savePlayerSpawnPoint
    end

    if targetSpawnPoint == nil then
        if this.StartSpawnPoint then
            targetSpawnPoint = player.startPlayerSpawnPoint            
        elseif this.LastSpawnPoint then
            targetSpawnPoint = player.lastPlayerSpawnPoint        
        elseif this.ReferencedSpawner and this.SpawnerRef ~= nil then
            targetSpawnPoint = this.SpawnerRef
        end
    end

    player.character:Respawn(targetSpawnPoint)
end

function this.OnTriggerEnter(collider)                       
    local character = collider.vObject:Cast("Character")        
    if character == nil then return end

    local player = character.player
    if player == nil then return end
    
    if this.OnPlayerCollided then
        this.OnPlayerCollided:Call(player)    
    end    

    script:AsyncCall(function() RespawnSequenceAsync(player) end)
end