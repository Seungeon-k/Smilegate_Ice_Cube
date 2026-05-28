
    local this = __CREATOR__.new()
        
    local serviceApi
    local scriptObject
    local soundService
    local world
    local buff


    local lifeTime = 5 
    local activeBuff = false
    local initialed = false
    local flyUpForce = 0  
    local owner 
    local effectObject
    local effectZippo

   

    
    this.LifeTime = __EX_VARIABLE__.float(5)
    this.IntervalTime = __EX_VARIABLE__.float(0.9)
    this.IntervalDuratioin = __EX_VARIABLE__.float(0.4)
    this.BuffEffect = __EX_VARIABLE__.vobject()
    this.ZippoEffect = __EX_VARIABLE__.vobject()
    this.BuffSound = __EX_VARIABLE__.asset.audioClip()

    this.OnChangeFlyUpForce = __EX_VARIABLE__.event("float")


    local first_force = 35
    local interval_startTime = 1
    local interval_time = 1
    local insideintervalDuration = 0

    

    local isIntervalSequence = false
    local conditionOnce = false
    local appliedEffecs = false 


    function this.OnEnable()
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        soundService = serviceApi.soundService
        world = serviceApi.world



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
        
        world = serviceApi.world
        soundService = serviceApi.soundService

        
        
    end
    
    
    function this.OnUpdate(deltaTime)

        if activeBuff == false then
            return 
        end

        lifeTime = lifeTime - deltaTime

        if lifeTime <= 0 then
            lifeTime = this.LifeTime
            activeBuff = false
            scriptObject:Log("time out")
            local go = scriptObject.parent.parent 

            local character = go:Cast("Character") 

            if character then
                scriptObject:Log("character")
                character:RemoveBuff(scriptObject.parent)
            end


        end

        this.ForceUpdate(deltaTime)
                        
    end

    function this.ChangeFlyUpForce(force)

        if force ~= flyUpForce then
            flyUpForce = force
            this.OnChangeFlyUpForce:Call(flyUpForce)
        end

        scriptObject:Log("Up Foce "..force)
        
    end


    
    function this.ForceUpdate(deltaTime)


        if activeBuff == false then
            return 
        end

        local spendTime = this.LifeTime - lifeTime
        spendTime = math.max(0, math.min(spendTime, this.LifeTime))

        if spendTime > interval_startTime then

            if isIntervalSequence == false then
                isIntervalSequence = true
                this.ChangeFlyUpForce(0)
            end

            conditionOnce = false

            if appliedEffecs == false then
                interval_time = interval_time - deltaTime

                if interval_time <= 0 then
                    insideintervalDuration = this.IntervalDuratioin
                    interval_time = 0
                    this.ChangeFlyUpForce(35)
                    appliedEffecs = true 
                end

                conditionOnce = true

            end

            if not conditionOnce and appliedEffecs then
                insideintervalDuration = insideintervalDuration - deltaTime
                if insideintervalDuration <= 0 then
                    interval_time = this.IntervalTime -- + insideintervalDuration
                    insideintervalDuration = 0
                    this.ChangeFlyUpForce(0)
                    appliedEffecs = false
                end
            end

        end
        
    end

    
    function this.OnBeforeAdded(character, buff)

        scriptObject:Log("OnBeforeAdded")
        
    end


    function this.OnAdded(character, buff)

        
        owner = character


        if this.BuffSound then
            soundService:Play(this.BuffSound)    
        end

        
        if this.BuffEffect then
            effectObject = world:Instantiate(this.BuffEffect, Vector3(0, 0, 0), Quaternion(0, 0, 0, 1))
            
            owner:AttachPart(effectObject, VFramework.CharacterPartsType.BackAccessory)
            effectObject.transform.localPosition = Vector3(0, 0, 0)
            effectObject.transform.localRotation = Quaternion.Euler(90, 0, 0)
            effectObject.transform:SyncTransform()
            

            -- todo 
            local particle = effectObject:GetComponentInChildren("ParticleSystem")

            particle:Play()

            
        end

        if this.ZippoEffect then
            effectZippo = world:Instantiate(this.ZippoEffect, Vector3(0, 0, 0), Quaternion(0, 0, 0, 1))
            
            owner:AttachPart(effectZippo, VFramework.CharacterPartsType.BackAccessory)
            effectZippo.transform.localPosition = Vector3(0,0.4, -0.7)
            effectZippo.transform.localRotation = Quaternion.Euler(90, 0, 0)
            effectZippo.transform:SyncTransform()

            


        end

        flyUpForce = first_force
        
        this.OnChangeFlyUpForce:Call(flyUpForce)


        lifeTime = this.LifeTime
        interval_time = this.IntervalTime

        activeBuff = true 


        
    end


    function this.OnBeforeRemoved(character, buff)


        
    end

    function this.OnRemoved(character, buff)

        activeBuff = false


        if effectObject then
            effectObject:Destroy()
            effectObject = nil
        end
        if effectZippo then
            effectZippo:Destroy()
            effectZippo = nil 
        end

        owner = character

        
    end


    function this.OnFreezed(character, buff)

        activeBuff = false

        if effectObject then
            effectObject:Destroy()
            effectObject = nil
        end
        if effectZippo then
            effectZippo:Destroy()
            effectZippo = nil 
        end



        
    end

     function this.OnResumed(character, buff)

        activeBuff = true


        owner = character



        if this.BuffEffect then
            effectObject = world:Instantiate(this.BuffEffect, Vector3(0, 0, 0), Quaternion(0, 0, 0, 1))
            -- Attach가 된 다음 부터 서버 로직에서 위치 수정 권한이 없으므로 먼저 설정한다. 
            effectObject.transform.localPosition = Vector3(0, 0, 0)
            effectObject.transform.localRotation = Quaternion.Euler(90, 0, 0)
            owner:AttachPart(effectObject, VFramework.CharacterPartsType.BackAccessory)
            

            -- todo 
            local particle = effectObject:GetComponentInChildren("ParticleSystem")

            particle:Play()

            
        end

        if this.ZippoEffect then
            effectZippo = world:Instantiate(this.ZippoEffect, Vector3(0, 0, 0), Quaternion(0, 0, 0, 1))
            -- Attach가 된 다음 부터 서버 로직에서 위치 수정 권한이 없으므로 먼저 설정한다. 
            effectZippo.transform.localPosition = Vector3(0,0.4, -0.7)
            effectZippo.transform.localRotation = Quaternion.Euler(90, 0, 0)
            owner:AttachPart(effectZippo, VFramework.CharacterPartsType.BackAccessory)
            


        end

        this.OnChangeFlyUpForce:Call(flyUpForce)


        
    end




