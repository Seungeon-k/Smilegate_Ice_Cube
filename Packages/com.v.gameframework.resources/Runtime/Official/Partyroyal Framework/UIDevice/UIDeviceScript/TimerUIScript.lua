
    local this = __CREATOR__.new()
        
    local serviceApi
    local soundService
    local scriptObject

    local nowPlaying = false
    local nowInfinite = false
    
    this.timerUI = __EX_VARIABLE__.vobject()

    this.textNormal = __EX_VARIABLE__.component.text()
    this.textState02 = __EX_VARIABLE__.component.text()
    this.textState03 = __EX_VARIABLE__.component.text()
    this.textState04 = __EX_VARIABLE__.component.text()

    this.sliderGauge1 = __EX_VARIABLE__.component.slider()
    this.sliderGauge2 = __EX_VARIABLE__.component.slider()
    this.sliderGauge3 = __EX_VARIABLE__.component.slider()

    this.xformNeedle = __EX_VARIABLE__.component.transform()

    this.animatorTimer = __EX_VARIABLE__.component.animator()
    this.animatorChangeEffect = __EX_VARIABLE__.component.animator()

    this.iconInfinite = __EX_VARIABLE__.vobject()

    this.soundClock = __EX_VARIABLE__.asset.audioClip()
    this.soundWarning = __EX_VARIABLE__.asset.audioClip()
    this.soundEarlyCount = __EX_VARIABLE__.asset.audioClip()

    this.RunningTime = __EX_VARIABLE__.float(90)

    this.WarningLevel1LimitTimeSeconds = __EX_VARIABLE__.float(45)
    this.WarningLevel2LimitTimeSeconds = __EX_VARIABLE__.float(25)
    this.EmergencyLimitTimeSeconds = __EX_VARIABLE__.float(10)

    this.OnWarning1Activated = __EX_VARIABLE__.event()
    this.OnWarning2Activated = __EX_VARIABLE__.event()
    this.OnEmergencyActivated = __EX_VARIABLE__.event()
    this.OnTimerCompleted = __EX_VARIABLE__.event()

    local function calculateTime(remainTimeSeconds)
        local minutes = Mathf.Floor(remainTimeSeconds / 60)
        local seconds = Mathf.Ceil(remainTimeSeconds % 60)
        if seconds == 60 then
            minutes = minutes + 1
            seconds = 0
        end
        return minutes, seconds
    end

    local function displayTimeText(displayer, remainTimeSeconds)

        if remainTimeSeconds <= this.EmergencyLimitTimeSeconds then
            displayer.text = string.format("%02d", remainTimeSeconds)
            return 0, remainTimeSeconds
        end

        local minutes, seconds = calculateTime(remainTimeSeconds)
        displayer.text = string.format("%02d:%02d", minutes, seconds)

        return minutes, seconds
    end

    local function displayTimeGauge(displayer, remainTimeSeconds)
        local timeRatio = math.max(0, remainTimeSeconds / this.RunningTime)
        local angle = 360 * timeRatio
        this.xformNeedle.localRotation = Quaternion.Euler(0,0,angle)
        displayer.value = 1 - timeRatio
    end

    local function isValidLimitTimes()
        if this.RunningTime < this.WarningLevel1LimitTimeSeconds or
        this.RunningTime < this.WarningLevel2LimitTimeSeconds or
        this.RunningTime < this.EmergencyLimitTimeSeconds then
            return false
        end

        if this.WarningLevel1LimitTimeSeconds < this.WarningLevel2LimitTimeSeconds or
        this.WarningLevel1LimitTimeSeconds < this.EmergencyLimitTimeSeconds then
            return false
        end

        if this.WarningLevel2LimitTimeSeconds < this.EmergencyLimitTimeSeconds then
            return false
        end

        return true
    end
    
    
    local function resetTimer()
        this.textNormal.transform.localScale = Vector3.one
        this.xformNeedle.localRotation = Quaternion.Euler(0, 0, 0)

        this.animatorTimer.enabled = false
        this.animatorChangeEffect.vObject:SetActive(false)

        displayTimeText(this.textNormal, this.RunningTime)
        displayTimeText(this.textState02, this.RunningTime)
        displayTimeText(this.textState03, this.RunningTime)
        displayTimeText(this.textState04, this.RunningTime)

        this.textNormal.vObject:SetActive(not nowInfinite)
        this.textState02.vObject:SetActive(false)
        this.textState03.vObject:SetActive(false)
        this.textState04.vObject:SetActive(false)

        this.sliderGauge1.value = 0
        this.sliderGauge2.value = 0
        this.sliderGauge3.value = 0

        this.sliderGauge1.vObject:SetActive(true)
        this.sliderGauge2.vObject:SetActive(false)
        this.sliderGauge3.vObject:SetActive(false)

        this.iconInfinite:SetActive(nowInfinite)

        nowPlaying = false
    end
    
    local displayedText
    local displayedSlider

    local function startTimer()

        if isValidLimitTimes() then

            this.animatorTimer.enabled = true
            this.animatorTimer:Play("Time_State_01", 0, 0)

            nowPlaying = true

            displayedText = this.textNormal
            displayedSlider = this.sliderGauge1

            print('[Timer] processTime')

        else
            print('Invalid limit time seconds variable')
            
        end
    end

    function this.OnStart()
    
        serviceApi = this.serviceApi
        soundService = serviceApi.soundService
        scriptObject = this.scriptObject

        resetTimer()
           
    end

    __EX_FUNCTION__(this, __EX_VARIABLE__.int())
    function this.ProcessTime(elapsedSeconds)
        if not nowPlaying then resetTimer(); return end

        local elapsedTimeSeconds = elapsedSeconds
        local remainTimeSeconds = this.RunningTime - elapsedTimeSeconds

        print('[Timer] processTime'.." / "..tostring(elapsedTimeSeconds))

        if remainTimeSeconds == this.WarningLevel1LimitTimeSeconds then

            displayedText.vObject:SetActive(false)
            displayedSlider.vObject:SetActive(false)

            displayedText = this.textState02
            displayedSlider = this.sliderGauge2

            this.animatorTimer:Play("Time_State_02",0,0)

            this.animatorChangeEffect.vObject:SetActive(true)
            this.animatorChangeEffect:Play("time_stage04_Open",0,0)
            
            soundService:Play(this.soundEarlyCount)

            this.OnWarning1Activated:Call()
        
        
        elseif remainTimeSeconds == this.WarningLevel2LimitTimeSeconds then

            displayedText.vObject:SetActive(false)
            displayedSlider.vObject:SetActive(false)

            displayedText = this.textState03
            displayedSlider = this.sliderGauge3

            this.animatorTimer:Play("Time_State_03",0,0)

            this.animatorChangeEffect.vObject:SetActive(true)
            this.animatorChangeEffect:Play("time_stage04_Open",0,0)

            soundService:Play(this.soundEarlyCount)

            this.OnWarning2Activated:Call()

        elseif remainTimeSeconds == this.EmergencyLimitTimeSeconds then

            displayedText.vObject:SetActive(false)
            displayedSlider.vObject:SetActive(false)

            displayedText = this.textState04
            displayedSlider = this.sliderGauge3

            this.animatorTimer:Play("Time_State_04",0,0)
            this.animatorChangeEffect.vObject:SetActive(false)

            this.OnEmergencyActivated:Call()

        end

        displayTimeText(displayedText, remainTimeSeconds)
        displayTimeGauge(displayedSlider, remainTimeSeconds)

        if remainTimeSeconds < 10 then
            soundService:Play(this.soundClock)

            if remainTimeSeconds <= 3 then
                soundService:Play(this.soundWarning)
            end
        end
    end

    __EX_FUNCTION__(this)
    function this.CompleteTime()
        if not nowInfinite then
            this.OnTimerCompleted:Call()
        end
    end


    __EX_FUNCTION__(this)
    function this.ShowControlUI()
        this.timerUI:SetActive(true)
    end

    __EX_FUNCTION__(this)
    function this.HideControlUI()
        this.timerUI:SetActive(false)
    end

    __EX_FUNCTION__(this)
    function this.StartTime()
        if not nowPlaying and not nowInfinite then
            print('[Timer] StartTime')
            startTimer()
        end
    end

    __EX_FUNCTION__(this)
    function this.ResetTime()

        nowInfinite = false

        if not nowPlaying then
            resetTimer()
        end

        nowPlaying = false
        
    end

    __EX_FUNCTION__(this)
    function this.RemoveTimeLimits()

        nowInfinite = true

        if not nowPlaying then
            resetTimer()
        end

        nowPlaying = false

    end

