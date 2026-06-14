
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
    local playerRecoveryTimer = 0
    local playerRecoveryLogged = false
    local playerRecoveryDepth = 0.2
    local playerRecoveryHeight = 0.55
    local playerRecoveryDuration = 0.4

    local raceTimerText
    local raceStatusText
    local finishLine
    local iceCollider
    local finishCollider
    local raceTimeRemaining = 120
    local startMessageRemaining = 2
    local raceState = "running"

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

    local function resolveLocalCharacter()
        if this.Target ~= nil and this.Target.transform ~= nil then
            return this.Target
        end

        if playerService == nil or playerService.localPlayer == nil then
            return nil
        end

        local character = playerService.localPlayer.character
        if character ~= nil then
            this.Target = character
            blockUpdate = false
        end
        return character
    end

    local function updatePlayerRecovery(deltaTime)
        if iceCube == nil or iceCube.transform == nil then
            resolveIceGauge()
        end

        local character = resolveLocalCharacter()
        if character == nil or character.transform == nil then return end
        if iceCube == nil or iceCube.transform == nil then return end

        local iceTransform = iceCube.transform
        local icePosition = iceTransform.position
        local iceTopY = icePosition.y + iceTransform.localScale.y * 0.5
        local characterPosition = character.transform.position
        local isBelow = characterPosition.y < iceTopY - playerRecoveryDepth
        local isFallingNearIce = character.isFalling == true
            and characterPosition.y < iceTopY + 0.5

        if playerRecoveryTimer <= 0 and (isBelow or isFallingNearIce) then
            playerRecoveryTimer = playerRecoveryDuration
            playerRecoveryLogged = false
        end

        if playerRecoveryTimer <= 0 then return end

        local recoveryPosition = Vector3(
            icePosition.x,
            iceTopY + playerRecoveryHeight,
            icePosition.z
        )

        pcall(function()
            character:SetControlBlocked(true)
        end)
        pcall(function()
            character:SetVelocity(Vector3(0, 0, 0))
        end)
        pcall(function()
            character:SetAngularVelocity(Vector3(0, 0, 0))
        end)
        local characterTransform = character.transform
        local moved = pcall(function()
            characterTransform:ChangePosition(recoveryPosition)
        end)
        if not moved then
            characterTransform.position = recoveryPosition
            pcall(function()
                characterTransform:SyncTransform()
            end)
        end
        pcall(function()
            character:SetIsOnIce(true)
        end)

        if not playerRecoveryLogged and scriptObject ~= nil then
            playerRecoveryLogged = true
            scriptObject:Log("[PlayerRecovery] Returned player to Ice_Cube.")
        end

        playerRecoveryTimer = playerRecoveryTimer - (deltaTime or 0.016)
        if playerRecoveryTimer <= 0 then
            pcall(function()
                character:SetControlBlocked(false)
            end)
        end
    end

    local function resolveText(uiName)
        if serviceApi.uiService == nil then return nil end

        local uiObject = serviceApi.uiService:GetChildUI("IceGaugeHUD_UI/" .. uiName)
        if uiObject == nil then
            uiObject = serviceApi.uiService:FindByName(uiName)
        end

        if uiObject == nil then return nil end
        return uiObject:GetComponent("TextMeshProUGUI")
    end

    local function resolveRaceHud()
        if raceTimerText == nil then
            raceTimerText = resolveText("RaceTimerText")
        end

        if raceStatusText == nil then
            raceStatusText = resolveText("RaceStatusText")
        end

        if iceCube == nil and serviceApi.world ~= nil then
            iceCube = serviceApi.world:GetVObject("Ice_Cube")
        end

        if finishLine == nil and serviceApi.world ~= nil then
            finishLine = serviceApi.world:GetVObject("Finish_Line")
        end

        if iceCollider == nil and iceCube ~= nil then
            iceCollider = iceCube:GetComponent("Collider")
        end

        if finishCollider == nil and finishLine ~= nil then
            finishCollider = finishLine:GetComponent("Collider")
        end
    end

    local function formatRaceTime(seconds)
        local totalSeconds = math.max(0, math.ceil(seconds))
        local minutes = math.floor(totalSeconds / 60)
        local remainingSeconds = totalSeconds % 60
        return string.format("%02d:%02d", minutes, remainingSeconds)
    end

    local function boundsOverlap(a, b)
        return a.min.x <= b.max.x and a.max.x >= b.min.x
            and a.min.y <= b.max.y and a.max.y >= b.min.y
            and a.min.z <= b.max.z and a.max.z >= b.min.z
    end

    local function hasReachedFinish()
        if iceCube == nil or finishLine == nil then return false end
        if iceCube.transform == nil or finishLine.transform == nil then return false end

        if iceCollider ~= nil and finishCollider ~= nil then
            local ok, overlapping = pcall(function()
                return boundsOverlap(iceCollider.bounds, finishCollider.bounds)
            end)
            if ok and overlapping then return true end
        end

        local icePosition = iceCube.transform.position
        local finishPosition = finishLine.transform.position
        local dx = icePosition.x - finishPosition.x
        local dz = icePosition.z - finishPosition.z
        return dx * dx + dz * dz <= 100
    end

    local function updateRaceHud(deltaTime)
        resolveRaceHud()

        if raceState == "running" then
            raceTimeRemaining = math.max(0, raceTimeRemaining - (deltaTime or 0))
            startMessageRemaining = math.max(0, startMessageRemaining - (deltaTime or 0))

            if hasReachedFinish() then
                raceState = "goal"
                if raceStatusText ~= nil then
                    raceStatusText.text = "GOAL"
                end
            elseif raceTimeRemaining <= 0 then
                raceState = "timeout"
                if raceStatusText ~= nil then
                    raceStatusText.text = "TIME OVER"
                end
            elseif raceStatusText ~= nil then
                if startMessageRemaining > 0 then
                    raceStatusText.text = "START!"
                else
                    raceStatusText.text = ""
                end
            end
        end

        if raceTimerText ~= nil then
            raceTimerText.text = formatRaceTime(raceTimeRemaining)
        end
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
        resolveRaceHud()
        scriptObject:Log("[PlayerRecovery] Recovery controller ready.")

        if raceTimerText ~= nil then
            raceTimerText.text = "02:00"
        end
        if raceStatusText ~= nil then
            raceStatusText.text = "START!"
        end

        if this.UseLocalPlayer and playerService ~= nil then
            playerService.OnCreateCharacter:AddListener(onCreateCharacter)
            playerService.OnDestroyCharacter:AddListener(OnDestroyCharacter)
        end
    end
    
    
    function this.OnUpdate(deltaTime)
        updateIceGauge(deltaTime)
        updateRaceHud(deltaTime)
        updatePlayerRecovery(deltaTime)

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

