
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local soundService



    local _maxSize = 1
    local _maxVectorSize


    local initialed = false
    local owner

    this.ForceScale = __EX_VARIABLE__.float(0.3)
 

    function this.OnEnable()

        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        soundService = serviceApi.soundService

        if initialed == true then
            return 
        end

        initialed = true 

        scriptObject.parent.OnAdded:AddListener(this.OnAdded)
        scriptObject.parent.OnRemoved:AddListener(this.OnRemoved)
        scriptObject.parent.OnResumed:AddListener(this.OnResumed)

    end

    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject

    end
    
    
    function this.OnUpdate(deltaTime)


    end
    
    function this.OnDestroy()

        if initialed == false then
            return 
        end

        scriptObject.parent.OnAdded:RemoveListener(this.OnAdded)
        scriptObject.parent.OnRemoved:RemoveListener(this.OnRemoved)
        scriptObject.parent.OnResumed:RemoveListener(this.OnResumed)
        
    end

    function this.OnAdded(character, buff)

        owner = character
        owner.externalForceScale = owner.externalForceScale * this.ForceScale

    end

    function this.OnRemoved(character, buff)

        owner = character
        owner.externalForceScale = owner.externalForceScale / this.ForceScale

    end

    function this.OnResumed(character, buff)

        owner = character
        owner.externalForceScale = owner.externalForceScale * this.ForceScale

    end

   
    __EX_FUNCTION__(this)
    function this.OnEnd()
        if owner then
            owner:RemoveBuff(scriptObject.parent)
        end
        
    end

