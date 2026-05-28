
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
    local ownerRigidbody
    local startEffect
    local activetEffect
    local soundIndex = -1

    this.LifeTime =  __EX_VARIABLE__.float(5)
    this.BuffSound = __EX_VARIABLE__.asset.audioClip()
    this.StartEffect = __EX_VARIABLE__.vobject()
    this.ActiveEffect = __EX_VARIABLE__.vobject()
    this.ReleaseEffect = __EX_VARIABLE__.vobject()
    this.Material = __EX_VARIABLE__.asset.material()


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

        if owner and owner.isKnockedDown == true then
            owner:CancelKnockBack()
            owner:SetVelocity(Vector3(0,0,0))
            owner.animator.speed = 0

        end

        local eps = 0.05 

        if ownerRigidbody then
            local vel = ownerRigidbody.velocity
            if math.abs(vel.x) > eps or math.abs(vel.z) > eps then
                vel.x = 0
                vel.z = 0
                if vel.y > 0 then
                    vel.y = 0
                end
                owner:SetVelocity(vel)
            end

            owner:SetAngularVelocity(Vector3(0,0,0))
            
        end

        if buffTime >= this.LifeTime then
            activeBuff = false

            if owner then
                owner:RemoveBuff(scriptObject.parent)
            end
        end
                
    end

    local function ApplyBuff()

        if not owner then
            return
        end
        


        -- Material 교체 하고 
        owner:OverrideMaterialOnAllParts(this.Material)
        -- Knockback Cancel 하고 
        owner:CancelKnockBack()
        owner:SetVelocity(Vector3(0,0,0))
        owner:SetAngularVelocity(Vector3(0,0,0))

        -- animation Speed 변경 하고 
        owner.animator.speed = 0
        -- Mass 값 변경 하고 
        owner:SetMass(100)
        --owner:SetRigidbodyConstraints(VFramework.RigidbodyConstraints.FreezeAll)
        owner.externalForceScale = 0

       

    end

    local function ReleaseBuff()

         if activetEffect then
            activetEffect:Destroy()
            activetEffect = nil
        end

        if not owner then
            return
        end

        -- animation Speed 변경 하고 
        owner.animator.speed = 1
        owner:RestoreMass()
        --owner:RestoreRigidbodyConstraints()
        owner:RestoreMaterialOnAllParts()
        owner.externalForceScale = 1



    end

    
    function this.OnDestroy()

    
        if initialed == false then 
            return 
        end

        scriptObject.parent.OnAdded:RemoveListener(this.OnAdded)
        scriptObject.parent.OnRemoved:RemoveListener(this.OnRemoved)
        scriptObject.parent.OnFreezed:RemoveListener(this.OnFreezed)
        scriptObject.parent.OnResumed:RemoveListener(this.OnResumed)


        if activetEffect then
            activetEffect:Destroy()
            activetEffect = nil
        end

        if activeBuff then
            ReleaseBuff() 
            
        end

        if soundIndex > 0 then
            soundService:Stop(soundIndex)
            soundIndex = -1 
        end
        
        
        
    end




    function this.OnAdded(character, buff)

        owner = character
        ownerRigidbody = owner:GetComponent("Rigidbody")

        activeBuff = true 

        local pos = owner.transform.position
        local rot = owner.transform.rotation
        if this.StartEffect then
            startEffect = world:Instantiate(this.StartEffect, pos, rot)  
        end
        if this.ActiveEffect then
            activetEffect = world:Instantiate(this.ActiveEffect, pos, rot)  
            activetEffect.transform.localPosition = Vector3(0, 0, 0)
            activetEffect.transform.localRotation = Quaternion.Euler(90, 0, 0)
            owner:AttachPart(activetEffect, VFramework.CharacterPartsType.None)

        end


        if this.BuffSound then
            soundIndex = soundService:Play(this.BuffSound)
        end


        ApplyBuff()



    end

    function this.OnRemoved(character, buff)

        activeBuff = false
        owner = character
        ownerRigidbody = owner:GetComponent("Rigidbody")

        if this.ReleaseEffect then
            local pos = owner.transform.position
            local rot = owner.transform.rotation
            world:Instantiate(this.ReleaseEffect, pos, rot)  
        end

        if soundIndex > 0 then
            soundService:Stop(soundIndex)
            soundIndex = -1 
        end

        ReleaseBuff()

    end

    function this.OnFreezed(character, buff)
        activeBuff = false
        
        if activetEffect then
            activetEffect:Destroy()
            activetEffect = nil
        end

        if soundIndex > 0 then
            soundService:Stop(soundIndex)
            soundIndex = -1 
        end
    end

    function this.OnResumed(character, buff)
        
        owner = character
        ownerRigidbody = owner:GetComponent("Rigidbody")
        
        local pos = owner.transform.position
        local rot = owner.transform.rotation

        activeBuff = true


        if this.ActiveEffect then
            activetEffect = world:Instantiate(this.ActiveEffect, pos, rot)  
            activetEffect.transform.localPosition = Vector3(0, 0, 0)
            activetEffect.transform.localRotation = Quaternion.Euler(90, 0, 0)
            owner:AttachPart(activetEffect, VFramework.CharacterPartsType.None)

        end


        ApplyBuff()

        

    end



