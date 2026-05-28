
    local this = __CREATOR__.new()
        
    local serviceApi    

    this.uiRoot = __EX_VARIABLE__.vobject()

    this.survivorCount = __EX_VARIABLE__.vobject.text()

    this.animator = __EX_VARIABLE__.component.animator()

    local function playCountAnimation(animName)
        if this.animator ~= nil then
            this.animator:Play(animName,0, 0)
        end
    end

    local function updateCurrentCount(count)
        local currCount = count

        playCountAnimation("Action")

        if this.survivorCount ~= nil then
            this.survivorCount.text = tostring(currCount)
        end
    end


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

    __EX_FUNCTION__(this, __EX_VARIABLE__.int())
    function this.SetNumber(count)
        updateCurrentCount(count)
    end


