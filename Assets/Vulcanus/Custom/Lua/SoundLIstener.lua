
    local this = __CREATOR__.new()

    this.Target = __EX_VARIABLE__.vobject()
    this.Offset = __EX_VARIABLE__.vector3()
    this.UseLocalPlayer = __EX_VARIABLE__.bool(true)
    
    local serviceApi
    local scriptObject
    local playerService
    local blockUpdate = false

    local _transform
    local _camera

    local iceCube
    local gaugeSlider
    local displayedGaugeRatio = 1
    local initialIceHeight = 3.0028605
    local gaugeConnectedLogged = false

    local function clamp01(value)
        if value < 0 then return 0 end
        if value > 1 then return 1 end
        return value
    end

    local function resolveIceGauge()
        if gaugeSlider == nil and serviceApi.uiService ~= nil then
            local gaugeObject = serviceApi.uiService:GetChildUI("IceGaugeHUD_UI/IceGaugeSlider")
            if gaugeObject == nil then
                gaugeObject = serviceApi.uiService:FindByName("IceGaugeSlider")
            end

            if gaugeObject ~= nil then
                gaugeSlider = gaugeObject:GetComponent("Slider")
            end
        end

        if iceCube == nil and serviceApi.world ~= nil then
            iceCube = serviceApi.world:GetVObject("Ice_Cube")
        end

        local connected = gaugeSlider ~= nil and iceCube ~= nil and iceCube.transform ~= nil
        if connected and not gaugeConnectedLogged then
            gaugeConnectedLogged = true
            scriptObject:Log("[IceGauge] Slider and Ice_Cube connected.")
        end

        return connected
    end

    local function updateIceGauge(deltaTime)
        if not resolveIceGauge() then return end

        local currentHeight = iceCube.transform.localScale.y
        local targetRatio = clamp01(currentHeight / initialIceHeight)
        local blend = clamp01(10 * (deltaTime or 0.016))

        displayedGaugeRatio = displayedGaugeRatio + (targetRatio - displayedGaugeRatio) * blend
        gaugeSlider.normalizedValue = displayedGaugeRatio
    end
    
    local function onCreateCharacter(player)
        if not this.UseLocalPlayer then return end

        if player.isLocalPlayer then
            this.Target = player.character
            blockUpdate = false
        end
    end

    local function OnDestroyCharacter(player)
        if not this.UseLocalPlayer then return end
        if player == nil then return end        

        if player.isLocalPlayer then
            if player.character == this.Target then                
                blockUpdate = true
            end
        end
    end
    
    function this.OnAwake()
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        playerService = serviceApi.playerService
    end

    function this.OnStart()
        _transform = scriptObject.parent.transform
        _camera = serviceApi.cameraService:GetGameCamera()
        resolveIceGauge()

        if this.UseLocalPlayer and playerService ~= nil then
            playerService.OnCreateCharacter:AddListener(onCreateCharacter)
            playerService.OnDestroyCharacter:AddListener(OnDestroyCharacter)
        end
    end
    
    
    function this.OnUpdate(deltaTime)
        updateIceGauge(deltaTime)

        if blockUpdate == true then return end
        if this.Target == nil or this.Target.transform == nil then return end
        if _camera == nil then return end
        if _transform == nil then return end        

        local targetTransform = this.Target.transform

        local pos = targetTransform.position

        pos.y = pos.y + this.Offset.y
        _transform.position = pos + targetTransform.forward * this.Offset.x

        if _camera ~= nil then
            _transform.rotation = _camera.transform.rotation
        end
    end
    
    function this.OnDestroy()
        if playerService then
            playerService.OnCreateCharacter:RemoveListener(onCreateCharacter)
        end
    end

    __EX_FUNCTION__(this, __EX_VARIABLE__.vobject())
    function this.SetTarget(target)        
        this.Target = target
        blockUpdate = false
    end

