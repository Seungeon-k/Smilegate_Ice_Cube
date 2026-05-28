
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
    local startEffect


    this.LifeTime =  __EX_VARIABLE__.float(10)
    this.BuffSound = __EX_VARIABLE__.asset.audioClip()
    this.BuffStartEffect = __EX_VARIABLE__.vobject()
    this.BuffEndEffect = __EX_VARIABLE__.vobject()
    

    function this.OnAwake()

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

    local function ApplyBuff()

        -- fly buff 중이면 fly buff 삭제
        -- local buffs = owner:GetBuffs()

        -- local flyup = nil
        -- if buffs then
        --     for i, v in ipairs(buffs) do
        --         if v.id == "Buff.Flyup" then
        --             flyup = v
        --         end
        --     end
        --     if flyup then
        --         owner:RemoveBuff(flyup)
        --     end
        -- end

        


        owner:SetControlBlocked(true)
        owner:CancelKnockBack()
        owner:StopState(VFramework.CharacterState.HeadButt)
        owner:StopState(VFramework.CharacterState.Jump)
        owner.animator:SetBool("isBalloonFreeze", true)
        owner.useGravity = false
        owner:SetVelocity(Vector3(0,0,0))
        owner:AddForce(Vector3(0, 1, 0), VFramework.ForceMode.VelocityChange)

        

    end

    local function ReleaseBuff()

       

        if not owner then
            return
        end

        
        owner:SetControlBlocked(false)
        owner.animator:SetBool("isBalloonFreeze", false)
        owner.useGravity = true

    end

    function this.OnAdded(character, buff)
        owner = character
        
        if this.BuffStartEffect then
            local pos = owner.transform.position
            local rot = owner.transform.rotation;
            startEffect = world:Instantiate(this.BuffStartEffect, pos, rot)  
            owner:AttachPart(startEffect, VFramework.CharacterPartsType.None)
            startEffect.transform.localPosition = Vector3(0, 0, 0)
            startEffect.transform.localRotation = Quaternion.Euler(0, 0, 0)
            startEffect.transform:SyncTransform()

        end

        if this.BuffSound then
            soundService:Play(this.BuffSound)    
        end

        ApplyBuff()

        activeBuff = true


    end

    function this.OnRemoved(character, buff)

        activeBuff = false

        owner = character

         if startEffect then
            startEffect:Destroy() 
            startEffect = nil 
        end

        if this.BuffEndEffect then
            local pos = owner.transform.position
            local rot =Quaternion.Euler(0, 0, 0)
            world:Instantiate(this.BuffEndEffect, pos, rot)  
            
        end


        ReleaseBuff()

    end

    function this.OnFreezed(character, buff)
        activeBuff = false
    end

    function this.OnResumed(character, buff)
        activeBuff = true
    end



