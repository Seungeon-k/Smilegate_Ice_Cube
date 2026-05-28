
    local this = __CREATOR__.new()
        
    local scriptObject
    local soundService
    local soundIndex = 0

    this.HudNoticeUI = __EX_VARIABLE__.vobject()
    this.NoticeText = __EX_VARIABLE__.component.text()

    this.Message = __EX_VARIABLE__.string("Please enter a message.")
    this.MessageLifetime = __EX_VARIABLE__.float(5)

    this.DisplaySound = _VASSET_.audioClip()

    local function setText(message)
        if this.NoticeText ~= nil then
            this.NoticeText.text = message
        end
    end

    local function setLifetime(lifeTime)
        this.MessageLifetime = lifeTime
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

        setText(this.Message)
    end    

    local function CloseAsync()
        VFramework.WaitForSeconds(this.MessageLifetime)
        this.HudNoticeUI:SetActive(false)
        stopSound()
    end

    __EX_FUNCTION__(this)
    function this.Show()
        this.HudNoticeUI:SetActive(true)
        playSound()
        scriptObject:AsyncCall(CloseAsync)
    end    
    
    function this.Hide()
        this.HudNoticeUI:SetActive(false)
        stopSound()        
    end

    __EX_FUNCTION__(this, 'string', 'float')
    function this.ShowMessage(message, lifeTime)

        setText(message)
        setLifetime(lifeTime)

        this.HudNoticeUI:SetActive(true)
        playSound()
        scriptObject:AsyncCall(CloseAsync)
    end
