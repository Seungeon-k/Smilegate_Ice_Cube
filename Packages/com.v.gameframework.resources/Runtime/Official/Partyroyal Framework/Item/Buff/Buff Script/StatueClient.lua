
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local inputService

    local initialed = false
    local isBlockInput = false
    

    function this.OnEnable()

        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        inputService = serviceApi.inputService

        initialed = true 
        isBlockInput = false

        scriptObject.parent.OnAdded:AddListener(this.OnAdded)
        scriptObject.parent.OnRemoved:AddListener(this.OnRemoved)
        scriptObject.parent.OnFreezed:AddListener(this.OnFreezed)
        scriptObject.parent.OnResumed:AddListener(this.OnResumed)

    end
    
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        inputService = serviceApi.inputService
        
        
    end
    
    
    function this.OnDestroy()

        if initialed == false then 
            return 
        end

        scriptObject.parent.OnAdded:RemoveListener(this.OnAdded)
        scriptObject.parent.OnRemoved:RemoveListener(this.OnRemoved)
        scriptObject.parent.OnFreezed:RemoveListener(this.OnFreezed)
        scriptObject.parent.OnResumed:RemoveListener(this.OnResumed)


        if isBlockInput == true then
            inputService.gate:Block("Statue", VFramework.InputChannel.Gameplay)
            isBlockInput = false
        end
        
    end

    function this.OnAdded(character, buff)

        if character.player.isLocalPlayer == false then
            return
        end


        if isBlockInput == false then
            inputService.gate:Block("Statue", VFramework.InputChannel.Gameplay)
            isBlockInput = true
        end
        

    end


    function this.OnRemoved(character, buff)

        if character.player.isLocalPlayer == false then
            return
        end


        if isBlockInput == true then
            inputService.gate:Unblock("Statue", VFramework.InputChannel.Gameplay)
            isBlockInput = false
        end

    end

    function this.OnFreezed(character, buff)
        
        if character.player.isLocalPlayer == false then
            return
        end

    end

    function this.OnResumed(character, buff)

        if character.player.isLocalPlayer == false then
            return
        end

    end