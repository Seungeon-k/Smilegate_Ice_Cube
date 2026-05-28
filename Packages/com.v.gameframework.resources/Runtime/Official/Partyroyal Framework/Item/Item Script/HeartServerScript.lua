
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local soundService

    local root
    local ground
    local delaytime = 0
    local checkVisible = ture

    
    this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
    this.VisibleDelay = __EX_VARIABLE__.float(0)
    this.PlayLife = __EX_VARIABLE__.int(1)
    this.AmountSound = __EX_VARIABLE__.asset.audioClip()


    function this.OnAwake()

        scriptObject = this.scriptObject
        root = scriptObject.parent

        ground = root:Find("Ground")

    
        if ground then
            ground:SetActive(this.IsVisibleOnStart)
        end
        
        checkVisible = this.IsVisibleOnStart
        
    end
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        soundService = serviceApi.soundService

        root = scriptObject.parent
        
    end
    
    
    function this.OnUpdate(deltaTime)

        if checkVisible == true then return end

        delaytime = delaytime + deltaTime

        if delaytime >= this.VisibleDelay then
            checkVisible = true
            if ground then
                ground:SetActive(true)
            end

        end
                
    end
    


    function this.OnTriggerEnter(collision)

        local character = collision.vObject:Cast("Character")  

        if character then
            local currentlife = character.player.life
            currentlife = currentlife + this.PlayLife
            character.player.life = currentlife

            if this.AmountSound then
                soundService:Play(this.AmountSound)
            end

            root:Destroy()

        end

        
    end


    __EX_FUNCTION__(this)
    function this.AppearOnEvent()

        checkVisible = true
        if ground then
            ground:SetActive(true)
        end
    end



    __EX_FUNCTION__(this)
    function this.DisappearOnEvent()

        checkVisible = true
        if ground then
            ground:SetActive(false)
        end
    end
   

