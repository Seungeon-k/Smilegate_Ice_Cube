
local this = __CREATOR__.new()

---@type VFramework.ServiceApi    
local serviceApi    

local script = nil
local appliedMaxSpeedCharacterByKey = {}
this.MaxVelocityBonus = __EX_VARIABLE__.float(0.5)
    
    
function this.OnStart()

    serviceApi = this.serviceApi
    script = this.scriptObject        
    
end    
    
function this.OnTriggerEnter(collision)
    --script:Log("enter trigger")
    local character = this.TryGetCharacter(collision)
    if character == nil then
        return
    end    

    script:Log("Apply Speed")
    this.ApplySpeedBonus(character)
end


function this.OnTriggerExit(collision)
    --script:Log("exit trigger")
    local character = this.TryGetCharacter(collision)
    if character == nil then
        return
    end

    script:Log("Remove Speed")
    this.RemoveSpeedBonus(character)    
end

function this.ApplySpeedBonus(character)
    if character == nil then
        return
    end

    if this.MaxVelocityBonus <= Mathf.Epsilon then
        return
    end

    if character.AddMaxVelocityBonus == nil then
        return
    end

    if character.player == nil or character.player.id == nil then
        return
    end

    local key = character.player.id
    if appliedMaxSpeedCharacterByKey[key] ~= nil then
        return
    end    

    character:AddMaxVelocityBonus(this.MaxVelocityBonus)
    appliedMaxSpeedCharacterByKey[key] = character
end

function this.RemoveSpeedBonus(character)
    if character == nil then
        return
    end

    if character.player == nil or character.player.id == nil then
        return
    end

    local key = character.player.id
    if appliedMaxSpeedCharacterByKey[key] == nil then
        return
    end    

    if this.MaxVelocityBonus <= Mathf.Epsilon then
        return
    end

    if character.AddMaxVelocityBonus == nil then
        return
    end    
    
    character:RemoveMaxVelocityBonus(this.MaxVelocityBonus)    
    appliedMaxSpeedCharacterByKey[key] = nil    
end

function this.TryGetCharacter(collision)
    if collision == nil then
        return nil, nil
    end

    local collideVObject = collision.vObject or collision
    if collideVObject == nil then
        return nil, nil
    end

    local character = collideVObject:Cast("Character")    
    if character == nil then
        return nil
    end        

    return character
end