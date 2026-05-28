
    local this = __CREATOR__.new()
        
    local serviceApi
    local scriptObject
    local soundService

    this.Automatic = __EX_VARIABLE__.bool(true)
    this.RandomPlay = __EX_VARIABLE__.bool(true)
    this.LoopPlay = __EX_VARIABLE__.bool(false)
    this.PlayList = __EX_VARIABLE__.list("AudioClip")
    this.EndFadeOutTime = __EX_VARIABLE__.float(0)

    this.StopAudioOnEvent = __EX_VARIABLE__.event()


    local isPlaying = false
    local currentIndex = 1
    local currentPlayId = -1
    local audioClips


        
    local function CheckAudioPlay()

        if currentIndex < 0 then
            isPlaying = false
            return
        end

        if isPlaying then
            isPlaying = soundService:IsBgmPlaying(currentPlayId)
            if not isPlaying then
                currentPlayId = -1 
                this.StopAudioOnEvent:Call()
            end
        end
        
    end
    
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        soundService = serviceApi.soundService

        audioClips = this.PlayList

        math.randomseed(os.time())


        if this.Automatic then
            this.PlaySound()
        end
        
    end
    

    
    function this.OnUpdate(deltaTime)

        CheckAudioPlay()
                
    end
    
    function this.OnDestroy()
        
    end


    function this.PlaySound()

        if isPlaying then
            return
        end

        if #audioClips <= 0 then
            return
        end

        local value 


        if this.RandomPlay then
            value = math.random(1, #audioClips)
        else
            value = currentIndex
            currentIndex = currentIndex + 1
            if currentIndex > #audioClips then
                currentIndex = 1 -- 끝까지 갔다면 다시 처음으로
            end
        end

        if audioClips[value] == nil then return end

        currentPlayId = soundService:PlayBgm(audioClips[value], 1, this.LoopPlay, this.EndFadeOutTime)

        if currentPlayId < 0 then
            return
        end
        
        isPlaying = true
        
    end


    --=======================================================



    __EX_FUNCTION__(this)
    function this.PlayAudio()

        CheckAudioPlay()

        if isPlaying then
            return
        end


        this.PlaySound()


    end


    __EX_FUNCTION__(this)
    function this.StopAudio()
        
        CheckAudioPlay()

         if not isPlaying then
            return
        end


        if currentPlayId < 0 then
            return
        end

        soundService:StopBgm(currentPlayId)
        currentPlayId = -1 
        isPlaying = false
        this.StopAudioOnEvent:Call()

    end

