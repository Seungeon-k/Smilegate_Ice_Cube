
    local this = __CREATOR__.new()
        
    local serviceApi
    

    this.uiRoot = __EX_VARIABLE__.vobject()

    this.currentCount = __EX_VARIABLE__.vobject.text()
    this.totalCount = __EX_VARIABLE__.vobject.text()

    this.animator = __EX_VARIABLE__.component.animator()
    
    this.remainingPlayersForWarningLevel1 = __EX_VARIABLE__.int()
    this.remainingPlayersForWarningLevel2 = __EX_VARIABLE__.int()

    local nowPlayingWarningLevel1 = false
    local nowPlayingWarningLevel2 = false

    local function playCountAnimation(animName)
        if this.animator ~= nil then
            this.animator:Play(animName,0, 0)
            nowPlayingWarningLevel1 = false
            nowPlayingWarningLevel2 = false
        end
    end

    local function getWholePlayerCount()
        local players = serviceApi.playerService:GetPlayers()
        return (players and #players) or 0
    end

    local function getMaxPlayerCount()
        return serviceApi.room.maxPlayerCount or 0
    end

    local function updateCurrentCount(count)
        local curCount = count

        if this.currentCount ~= nil then
            this.currentCount.text = tostring(curCount)
        end
        
        if not nowPlayingWarningLevel1 and not nowPlayingWarningLevel2 then
            
            if this.remainingPlayersForWarningLevel1 > 0 and curCount <= this.remainingPlayersForWarningLevel1 then
                this.ActivateWarningLevel1()
            end
        end

        if not nowPlayingWarningLevel2 then

            if this.remainingPlayersForWarningLevel2 > 0 and curCount <= this.remainingPlayersForWarningLevel2 then
                this.ActivateWarningLevel2()
            end
        end
    end


    local frontNumber
    local backNumber

    function this.OnStart()

        serviceApi = this.serviceApi

        playCountAnimation("None")

    end

    __EX_FUNCTION__(this)
    function this.ShowUI()
        this.uiRoot:SetActive(true)
    end

    __EX_FUNCTION__(this)
    function this.HideUI()
        this.uiRoot:SetActive(false)
    end

    __EX_FUNCTION__(this)
    function this.ActivateWarningLevel1()
        if this.animator ~= nil then
            this.animator:Play("HUD_Survivor_Finish1",0, 0)
            nowPlayingWarningLevel1 = true
        end
    end

    __EX_FUNCTION__(this)
    function this.ActivateWarningLevel2()
        if this.animator ~= nil then
            this.animator:Play("HUD_Survivor_Finish2",0, 0)
            nowPlayingWarningLevel2 = true
        end
    end

    __EX_FUNCTION__(this)
    function this.SetTotalCountToWholePlayer()
        backNumber = getWholePlayerCount()
        if this.totalCount ~= nil then
            this.totalCount.text = "/" .. tostring(backNumber)
        end
    end


    __EX_FUNCTION__(this)
    function this.SetTotalCountToMaxPlayer()
        backNumber = getMaxPlayerCount()
        if this.totalCount ~= nil then
            this.totalCount.text = "/" .. tostring(backNumber)
        end
    end

    __EX_FUNCTION__(this, __EX_VARIABLE__.int())
    function this.SetFrontNumber(count)
        frontNumber = count

        updateCurrentCount(frontNumber)
    end

    __EX_FUNCTION__(this, __EX_VARIABLE__.int())
    function this.SetBackNumber(count)
        backNumber = count
        if this.totalCount ~= nil then
            this.totalCount.text = "/" .. tostring(backNumber)
        end
    end

