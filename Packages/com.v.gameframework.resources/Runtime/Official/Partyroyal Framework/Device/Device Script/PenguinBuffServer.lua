
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject


    this.BuffApply = __EX_VARIABLE__.vobject.buff()
    
    
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        
    end
    
    
    function this.OnUpdate(deltaTime)
                
    end
    
    function this.OnDestroy()
        
    end

    __EX_FUNCTION__(this, __EX_VARIABLE__.vobject.player())
    function this.ApplyAssignedBuff(player)

        if player and player.character and this.BuffApply then
            player.character:AddBuff(this.BuffApply)
        end

    end

