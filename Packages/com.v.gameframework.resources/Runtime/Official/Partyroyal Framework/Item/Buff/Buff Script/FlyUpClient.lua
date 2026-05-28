
    local this = __CREATOR__.new()
        
    local serviceApi
    local scriptObject
    local playerService 

    local fly_force  = 0

    local owner
    

    local initialed = false
    local activeBuff = false

    
    function this.OnEnable()
        
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        playerService = serviceApi.playerService

        if initialed == true then
            return 
        end

        initialed = true 
        

        scriptObject.parent.OnBeforeAdded:AddListener(this.OnBeforeAdded)
        scriptObject.parent.OnAdded:AddListener(this.OnAdded)
        scriptObject.parent.OnBeforeRemoved:AddListener(this.OnBeforeRemoved)
        scriptObject.parent.OnRemoved:AddListener(this.OnRemoved)
        scriptObject.parent.OnFreezed:AddListener(this.OnFreezed)
        scriptObject.parent.OnResumed:AddListener(this.OnResumed)

    end
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject

        playerService = serviceApi.playerService

        
    end
    
    
    function this.OnFixedUpdate(deltaTime)
        this.ForceUpdate(deltaTime)
                
    end

    
    function this.ForceUpdate(deltaTime)


        if not activeBuff then
            return
        end


        if fly_force == 0 then
            return 
        end


        if not owner or owner.player.isLocalPlayer == false then
            return 
        end

        if fly_force ~= 0 then
            owner:AddForce(Vector3(0, fly_force, 0), VFramework.ForceMode.Acceleration)
        end
        


    end
    
    function this.OnDestroy()
        
    end


        
    function this.OnBeforeAdded(character, buff)

        
        if character.player.isLocalPlayer == false then
            return 
        end
        owner = character


        
    end

    function this.OnAdded(character, buff)

        
        if character.player.isLocalPlayer == false then
            return 
        end
        
        owner = character
        owner.animator:SetBool("isBurn", true)

        owner:StopState(VFramework.CharacterState.HeadButt)
        owner:StopState(VFramework.CharacterState.Jump)
        


        owner:SetVelocity(Vector3(0, 0, 0))
        
        activeBuff = true 

        
    end

    function this.OnBeforeRemoved(character, buff)

        
        if character.player.isLocalPlayer == false then
            return 
        end

        
        
        

    end

    function this.OnRemoved(character, buff)

        if character.player.isLocalPlayer == false then
            return 
        end


        character.animator:SetBool("isBurn", false)
        owner = nil 

        activeBuff = false

      

      

    end

    function this.OnFreezed(character, buff)

         if character.player.isLocalPlayer == false then
            return 
        end

        owner = nil 
        activeBuff = false



    end


    function this.OnResumed(character, buff)

         if character.player.isLocalPlayer == false then
            return 
        end

        owner = character
        owner.animator:SetBool("isBurn", false)
        activeBuff = true 

    end


    __EX_FUNCTION__(this, __EX_VARIABLE__.float())
    function this.OnChangeFlyForce(force)

     
        fly_force = force 

        

    end
