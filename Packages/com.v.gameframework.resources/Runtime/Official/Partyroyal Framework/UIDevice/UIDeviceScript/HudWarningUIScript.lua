
    local this = __CREATOR__.new()
        
    local scriptObject
    local soundService
    local soundIndex = 0

    this.HudNoticeUI = __EX_VARIABLE__.vobject()
    this.NoticeText = __EX_VARIABLE__.component.text()

    this.Message = __EX_VARIABLE__.string("Please enter a message.")
    this.MessageLifetime = __EX_VARIABLE__.float(5)

    this.DisplaySound = _VASSET_.audioClip()

    this.VTweenObjects = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())

    local vtweens = {}

    local function setText(message)
        if this.NoticeText ~= nil then
            this.NoticeText.text = message
        end
    end

    local function setLifetime(lifeTime)
        this.MessageLifetime = lifeTime
    end

    local function playTweens()
        for i,v in ipairs(vtweens) do
            v:Play()
        end
    end

    local function stopTweens()
        for i,v in ipairs(vtweens) do
            v:Stop()
        end
    end

    local function playSound()
        if soundService ~= nil and this.DisplaySound ~= nil then
            soundIndex = soundService:Play(this.DisplaySound)
        end
    end

    local function stopSound()
        if soundIndex > 0 then
            soundService:Stop(soundIndex)
        end
    end

    function this.OnStart()
    
        scriptObject = this.scriptObject
        soundService = this.serviceApi.soundService

        for _, tweenObject  in ipairs(this.VTweenObjects) do
            local compList = tweenObject:GetComponents('VTween')
            for _, comp in ipairs(compList) do                
                table.insert(vtweens, comp)
            end
        end

        setText(this.Message)
    end    

    local function CloseAsync()
        VFramework.WaitForSeconds(this.MessageLifetime)
        this.HudNoticeUI:SetActive(false)
        stopSound()
        stopTweens()
    end

    __EX_FUNCTION__(this)
    function this.Show()
        this.HudNoticeUI:SetActive(true)
        playSound()
        playTweens()

        scriptObject:AsyncCall(CloseAsync)
    end

    __EX_FUNCTION__(this, 'string', 'float')
    function this.ShowMessage(message, lifeTime)

        setText(message)
        setLifetime(lifeTime)

        this.HudNoticeUI:SetActive(true)
        playSound()
        playTweens()

        scriptObject:AsyncCall(CloseAsync)
    end
