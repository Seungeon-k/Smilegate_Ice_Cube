
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject

    
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        
    end
    
    function this.OnTriggerEnter(collider)
        
        if collider.vObject then
            local character = collider.vObject:Cast("PenguinCharacter")
            if character then
                character:SetIsOnIce(true)
            end
        end

    end

    function this.OnTriggerExit(collider)

        if collider.vObject then
            local character = collider.vObject:Cast("PenguinCharacter")
            if character then
                character:SetIsOnIce(false)
            end
        end

    end

    

