
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local soundService
    local world

    local initialed = false
    local activeBuff = false
    local buffTime  = 0
    local owner

    this.LifeTime =  __EX_VARIABLE__.float(2)
    this.AdditionalSpeed =  __EX_VARIABLE__.float(10)
    this.HeadbuttingForceScale = __EX_VARIABLE__.float(2.5)
    this.ActionBuff = __EX_VARIABLE__.vobject()
    this.BuffSound = __EX_VARIABLE__.asset.audioClip()

    
     
    

    function this.OnEnable()

        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        soundService = serviceApi.soundService
        world = serviceApi.world

        if initialed == true then
            return 
        end
        initialed = true 

        scriptObject.parent.OnAdded:AddListener(this.OnAdded)
        scriptObject.parent.OnRemoved:AddListener(this.OnRemoved)
        scriptObject.parent.OnFreezed:AddListener(this.OnFreezed)
        scriptObject.parent.OnResumed:AddListener(this.OnResumed)

        buffTime = 0


    end
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        
    end
    
    
    function this.OnUpdate(deltaTime)

        if activeBuff == false then
            return 
        end

        buffTime = buffTime + deltaTime

        if buffTime >= this.LifeTime then
            activeBuff = false

            if owner then
                owner:RemoveBuff(scriptObject.parent)
            end
        end
                
    end
    
    function this.OnDestroy()

        if initialed == false then
            return 
        end

        scriptObject.parent.OnAdded:RemoveListener(this.OnAdded)
        scriptObject.parent.OnRemoved:RemoveListener(this.OnRemoved)
        scriptObject.parent.OnFreezed:RemoveListener(this.OnFreezed)
        scriptObject.parent.OnResumed:RemoveListener(this.OnResumed)
        
    end

    function this.OnAdded(character, buff)

        owner = character
        owner.maxSpeed = owner.maxSpeed + this.AdditionalSpeed
        owner.headbuttingForceScale = owner.headbuttingForceScale * this.HeadbuttingForceScale

        activeBuff = true 

        if this.ActionBuff then
            local pos = owner.transform.position - owner.transform.forward * 0.6;
            pos.y = pos.y + 0.7
            local rot = owner.transform.rotation;
            local dust = world:Instantiate(this.ActionBuff, pos, rot)  

        end

        if this.BuffSound then
            soundService:Play(this.BuffSound)    
        end

    end

    function this.OnRemoved(character, buff)
        activeBuff = false
        owner = character
        owner.maxSpeed = owner.maxSpeed - this.AdditionalSpeed
        owner.headbuttingForceScale = owner.headbuttingForceScale / this.HeadbuttingForceScale
    end

    function this.OnFreezed(character, buff)

        activeBuff = false

    end

    function this.OnResumed(character, buff)
        activeBuff = true
        owner = character
        owner.maxSpeed = owner.maxSpeed + this.AdditionalSpeed
        owner.headbuttingForceScale = owner.headbuttingForceScale * this.HeadbuttingForceScale
    end


