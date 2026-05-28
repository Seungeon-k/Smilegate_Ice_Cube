
    local this = __CREATOR__.new()
        
    local scriptObject
    local soundService

    this.readyUI  = __EX_VARIABLE__.vobject()
    this.startUI  = __EX_VARIABLE__.vobject()
    this.successUI  = __EX_VARIABLE__.vobject()
    this.failUI  = __EX_VARIABLE__.vobject()
    this.endUI  = __EX_VARIABLE__.vobject()
    this.roundEndUI  = __EX_VARIABLE__.vobject()
    this.finalStageStartUI  = __EX_VARIABLE__.vobject()
    this.finalStageEndUI  = __EX_VARIABLE__.vobject()
    this.countdownUI  = __EX_VARIABLE__.vobject()
    this.countdownImage = __EX_VARIABLE__.component.image()

    this.readySound  = _VASSET_.audioClip()
    this.startSound  = _VASSET_.audioClip()
    this.successSound  = _VASSET_.audioClip()
    this.failSound  = _VASSET_.audioClip()
    this.endSound  = _VASSET_.audioClip()
    this.roundEndSound  = _VASSET_.audioClip()
    this.finalStageStartSound  = _VASSET_.audioClip()
    this.finalStageEndSound  = _VASSET_.audioClip()
    this.countdownSound  = _VASSET_.audioClip()

    this.countdownSprite = __EX_VARIABLE__.list(__EX_VARIABLE__.asset.sprite())

    local playSoundIndex = 0

    --[[
    local allUIs = {
        this.readyUI,
        this.startUI,
        this.successUI,
        this.failUI,
        this.endUI,
        this.roundEndUI,
        this.finalStageStartUI,
        this.finalStageEndUI,
        this.countdownUI
    }
    ]]--

    local allUIs = {}
    function this.OnStart()
    
        scriptObject = this.scriptObject
        soundService = this.serviceApi.soundService

        table.insert(allUIs,this.readyUI)
        table.insert(allUIs,this.startUI)
        table.insert(allUIs,this.successUI)
        table.insert(allUIs,this.failUI)
        table.insert(allUIs,this.endUI)
        table.insert(allUIs,this.roundEndUI)
        table.insert(allUIs,this.finalStageStartUI)
        table.insert(allUIs,this.finalStageEndUI)
        table.insert(allUIs,this.countdownUI)
        
    end

    local currentAnimator = nil
    local currentEventUI = nil
    local function traceAnimationFinished(eventUI)
        currentEventUI = eventUI
        _, currentAnimator = eventUI:GetComponentInChildrenByType(typeof(VFramework.Animator))
    end

    function this.OnUpdate()
        if currentAnimator ~= nil then
            local stateInfo = currentAnimator:GetCurrentAnimatorStateInfo(0)
            if stateInfo.normalizedTime >= 1 and not currentAnimator:IsInTransition(0) then
                currentEventUI:SetActive(false)
                currentAnimator = nil
                currentEventUI = nil
            end
        end
    end

    local function hideAll()
        for i, ui in ipairs(allUIs) do
            ui:SetActive(false)
        end

        if playSoundIndex > 0 then
            soundService:Stop(playSoundIndex)
            playSoundIndex = 0
        end
    end

    local function playSound(displaySound)
        if soundService ~= nil and displaySound ~= nil then
            playSoundIndex = soundService:Play(displaySound)
        end
    end

    __EX_FUNCTION__(this)
    function this.ShowReadyUI()
        hideAll()
        this.readyUI:SetActive(true)
        playSound(this.readySound)
    end

    __EX_FUNCTION__(this)
    function this.ShowStartUI()
        hideAll()
        this.startUI:SetActive(true)
        playSound(this.startSound)
    end

    __EX_FUNCTION__(this)
    function this.ShowSuccessUI()
        hideAll()
        this.successUI:SetActive(true)
        playSound(this.successSound)
    end

    __EX_FUNCTION__(this)
    function this.ShowFailUI()
        hideAll()
        this.failUI:SetActive(true)
        playSound(this.failSound)
    end

    __EX_FUNCTION__(this)
    function this.ShowEndUI()
        hideAll()
        this.endUI:SetActive(true)
        playSound(this.endSound)

        traceAnimationFinished(this.endUI)
    end

    __EX_FUNCTION__(this)
    function this.ShowRoundEndUI()
        hideAll()
        this.roundEndUI:SetActive(true)
        playSound(this.roundEndSound)
    end

    __EX_FUNCTION__(this)
    function this.ShowFinalStageStartUI()
        hideAll()
        this.finalStageStartUI:SetActive(true)
        playSound(this.finalStageStartSound)
    end

    __EX_FUNCTION__(this)
    function this.ShowFinalStageEndUI()
        hideAll()
        this.finalStageEndUI:SetActive(true)
        playSound(this.finalStageEndSound)
    end

    local function setSpecificCountdownSprite(countdownValue)
        if this.countdownImage == nil then return end
        if countdownValue >= 0 and countdownValue < #this.countdownSprite then
            this.countdownImage.sprite = this.countdownSprite[countdownValue + 1]
            scriptObject:Log("Countdown Sprite = " .. tostring(countdownValue))
        end
    end

    local function updateCountdownUI(countdownValue)
        for i = countdownValue, 1, -1 do
            setSpecificCountdownSprite(i)
            VFramework.WaitForSeconds(1)
        end

        this.countdownUI:SetActive(false)
    end

    local function showCountdown3UI()
        updateCountdownUI(3)
    end

    local function showCountdown5UI()
        updateCountdownUI(5)
    end

    __EX_FUNCTION__(this)
    function this.ShowCountdown3UI()
        hideAll()
        this.countdownUI:SetActive(true)
        playSound(this.countdownSound)

        scriptObject:AsyncCall(showCountdown3UI)
    end

    __EX_FUNCTION__(this)
    function this.ShowCountdown5UI()
        hideAll()
        this.countdownUI:SetActive(true)
        playSound(this.countdownSound)

        scriptObject:AsyncCall(showCountdown5UI)
    end
    
    function this.Hide()
        hideAll()
    end