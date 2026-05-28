
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local soundService    
    local playerService

    local _maxSize = 1
    local _maxVectorSize


    local initialed = false
    local activeBuff = false
    local owner
    local startScale 
    local sizeUpStep = 1
    local stepTime = 0
    local stepScale
    local sizeDownStep = 1
    local sizeProcess = 0  -- 0 : size up, 1 : size hold, 2 : size down

    this.LifeTime = __EX_VARIABLE__.float(6)
    this.CharacterScale = __EX_VARIABLE__.float(2)
    this.StartSound = __EX_VARIABLE__.asset.audioClip()
    this.EndSound = __EX_VARIABLE__.asset.audioClip()

    this.OnEnd = __EX_VARIABLE__.event()


    local upStepScales = {
        0, 0.4, 0.2, 0.5, 0.3, 0.6, 1
    }
    local upStepTimes = {
        0.1, 0.125, 0.15, 0.175, 0.2, 0.225, 0.125
    }

    local downStepScales = {
        1, 0.6, 0.3, 0.5, 0.2, 0.4, 0
    }
    local downStepTimes = {
        0.125, 0.225, 0.2, 0.175, 0.15, 0.125, 0.1, 0.1
    }


    
    function this.OnEnable()

        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        soundService = serviceApi.soundService
        playerService = serviceApi.playerService

        if initialed == true then
            return 
        end

        initialed = true 

        scriptObject.parent.OnAdded:AddListener(this.OnAdded)
        scriptObject.parent.OnRemoved:AddListener(this.OnRemoved)
        scriptObject.parent.OnFreezed:AddListener(this.OnFreezed)
        scriptObject.parent.OnResumed:AddListener(this.OnResumed)

    end

    
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject

        _maxVectorSize = Vector3(1, 1, 1)
        startScale = Vector3(1, 1, 1)
        
    end

    local function NextUpStep()

        sizeUpStep = sizeUpStep + 1 
        stepTime = 0
        startScale = stepScale

        if #upStepScales < sizeUpStep then
            sizeProcess = 1
            owner.transform.localScale = stepScale
            return 
        end

        stepScale = Vector3(1, 1, 1) + Vector3(1, 1, 1) * ( (this.CharacterScale - 1 ) * upStepScales[sizeUpStep] )
        
    end

    local function ChangeScale()
        local sc = this.EaseLinear(stepTime, upStepTimes[sizeUpStep], startScale, stepScale)
        return sc
    end

    local function NextDownStep()

        sizeDownStep = sizeDownStep + 1 
        stepTime = 0
        startScale = stepScale

        if #upStepScales < sizeDownStep then
            --sizeProcess = 0
            owner.transform.localScale = Vector3(1, 1, 1)
            sizeDownStep = 1
            activeBuff = false
            --owner:RemoveBuff(scriptObject.parent)
            this.OnEnd:Call()

            return 
        end

        stepScale = Vector3(1, 1, 1) + Vector3(1, 1, 1) * ( (this.CharacterScale - 1 ) * downStepScales[sizeDownStep] )
        
    end
    local function ChangeDownScale()
        local sc = this.EaseLinear(stepTime, downStepTimes[sizeDownStep], startScale, stepScale)
        return sc
    end
    
    
    function this.OnUpdate(deltaTime)

        if activeBuff == false then
            return 
        end

        if sizeProcess == 0 then
            if stepTime > upStepTimes[sizeUpStep]   then
                NextUpStep()
            else 
                owner.transform.localScale = ChangeScale()
                stepTime = stepTime + deltaTime
            end
        elseif sizeProcess == 1 then
            if stepTime > this.LifeTime then
                stepTime = 0
                sizeProcess = 2
                if this.EndSound then
                    soundService:Play(this.EndSound)   
                end
            else
                stepTime = stepTime + deltaTime

            end
        elseif sizeProcess == 2 then
            if stepTime > downStepTimes[sizeDownStep]   then
                NextDownStep()
            else 
                owner.transform.localScale = ChangeDownScale()
                stepTime = stepTime + deltaTime
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

        if this.StartSound then
            soundService:Play(this.StartSound)    
        end

        if character.player.isLocalPlayer == false then
            return
        end

        sizeProcess = 0 
        stepTime = 0 

        startScale = owner.transform.localScale
        stepScale = Vector3(1, 1, 1)
        sizeUpStep = 1

        activeBuff = true 

    end

    function this.OnRemoved(character, buff)

        activeBuff = false
        owner = character

        if character.player.isLocalPlayer == false then
            return
        end

        owner.transform.localScale = Vector3(1, 1, 1)

    end

    function this.OnFreezed(character, buff)

        activeBuff = false

    end

    function this.OnResumed(character, buff)

        owner = character

        if character.player.isLocalPlayer == false then
            return
        end

        activeBuff = true


    end

    function this.EaseLinear(elapsedTime, maxTime, startValue, endValue)
        -- Mathf.Clamp 대체
        if elapsedTime < 0 then elapsedTime = 0 end
        if elapsedTime > maxTime then elapsedTime = maxTime end

        if maxTime == 0 then
            -- 0으로 나누기 방지: 시간이 0이면 즉시 endValue로 처리(원하는 정책에 맞게 startValue로 바꿔도 됨)
            return endValue
        end

        if elapsedTime == maxTime then
            return endValue
        else
            local t = elapsedTime / maxTime
            return (endValue - startValue) * t + startValue
        end
    end

