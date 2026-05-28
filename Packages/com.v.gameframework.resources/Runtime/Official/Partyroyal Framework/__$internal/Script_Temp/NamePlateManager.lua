
    local this = __CREATOR__.new()
        
    local serviceApi
    local scriptObject
    local playerService

    this.UIPreset = __EX_VARIABLE__.vobject()

    local namePlates = {}

    local function createNamePlate(player)

        local presetUI = serviceApi.uiService:Instantiate(this.UIPreset)
        presetUI:SetParent(scriptObject.parent)

        return presetUI
    end

    local function attachToCharacter(player)
    end

    local function onPlayerReady(player)
        if player == nil then return end
        if namePlates[player] ~= nil then return end

        local namePlateUI = createNamePlate(player)

        namePlates[player] = namePlateUI
    end

    local function onPlayerLeave(player)

        if player ~= nil and namePlates[player] ~= nil then
            namePlates[player] = nil
        end

    end

    local function onCreateCharacter(player)
        if namePlates[player] == nil then return end

        local namePlateUI = namePlates[player]
        local namePlateScript = namePlateUI.NamePlatePresetUIScript:GetLua()

        namePlateScript.SetTargetPlayer(player)
    end

    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        playerService = serviceApi.playerService


        if playerService then
        
            playerService.OnPlayerReady:AddListener(onPlayerReady)
            playerService.OnPlayerLeave:AddListener(onPlayerLeave)
            playerService.OnCreateCharacter:AddListener(onCreateCharacter)
        
        end
    end

    function this.OnDestroy()
        if playerService then
        
            playerService.OnPlayerReady:RemoveListener(onPlayerReady)
            playerService.OnPlayerLeave:RemoveListener(onPlayerLeave)
            playerService.OnCreateCharacter:RemoveListener(onCreateCharacter)
        
        end
    end

    __EX_FUNCTION__(this)
    function this.ShowControlUI()
        for _, plate in pairs(namePlates) do
            plate:SetActive(true)
        end
    end

    __EX_FUNCTION__(this)
    function this.HideControlUI()
        for _, plate in pairs(namePlates) do
            plate:SetActive(false)
        end
    end

