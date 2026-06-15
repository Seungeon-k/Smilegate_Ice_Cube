
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
    local playerRecoveryCooldownTimer = 0
    local playerRecoveryLogged = false
    local playerRecoveryDepth = 1.0
    local playerRecoveryHeight = 1.0
    local playerRecoveryDuration = 0.18
    local playerRecoveryCooldown = 1.0
    local playerEdgeMargin = -1.0

    local raceTimerText
    local raceTimerObject
    local raceStatusText
    local raceStatusObject
    local finishLine
    local iceCollider
    local finishCollider
    local icePlatformController
    local raceDuration = 150
    local raceTimeRemaining = raceDuration
    local startMessageRemaining = 2
    local raceState = "running"
    local raceEnded = false
    local startFeedback
    local goalFeedback
    local failFeedback
    local startFeedbackPlayed = false
    local statusPulseTimer = 0
    local statusPulseScale

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

    local function getPlayerCharacter(player)
        if player == nil then return nil end

        local character = player.character
        if character == nil then
            character = player.Character
        end

        return character
    end

    local function forEachPlayerCharacter(callback)
        local visited = {}
        local localCharacter = resolveLocalCharacter()
        if localCharacter ~= nil then
            visited[localCharacter] = true
            callback(localCharacter)
        end

        if playerService == nil then return end

        local getPlayers = playerService.GetPlayers
        if getPlayers == nil then
            getPlayers = playerService.getPlayers
        end
        if getPlayers == nil then return end

        local ok, players = pcall(function()
            return getPlayers(playerService)
        end)
        if not ok or players == nil then return end

        pcall(function()
            for i = 1, #players do
                local character = getPlayerCharacter(players[i])
                if character ~= nil and visited[character] == nil then
                    visited[character] = true
                    callback(character)
                end
            end
        end)

        pcall(function()
            for _, player in pairs(players) do
                local character = getPlayerCharacter(player)
                if character ~= nil and visited[character] == nil then
                    visited[character] = true
                    callback(character)
                end
            end
        end)
    end

    local function updatePlayerRecovery(deltaTime)
        if raceEnded then return end
        deltaTime = deltaTime or 0.016

        if iceCube == nil or iceCube.transform == nil then
            resolveIceGauge()
        end

        local character = resolveLocalCharacter()
        if character == nil or character.transform == nil then return end
        if iceCube == nil or iceCube.transform == nil then return end

        local iceTransform = iceCube.transform
        local icePosition = iceTransform.position
        local iceScale = iceTransform.localScale
        local iceTopY = icePosition.y + math.abs(iceScale.y) * 0.5
        local characterPosition = character.transform.position
        local isBelow = characterPosition.y < iceTopY - playerRecoveryDepth
        local halfX = math.max(math.abs(iceScale.x) * 0.5 - playerEdgeMargin, 1.45)
        local halfZ = math.max(math.abs(iceScale.z) * 0.5 - playerEdgeMargin, 1.45)
        local safeX = math.max(
            icePosition.x - halfX,
            math.min(characterPosition.x, icePosition.x + halfX)
        )
        local safeZ = math.max(
            icePosition.z - halfZ,
            math.min(characterPosition.z, icePosition.z + halfZ)
        )
        local isOutside = characterPosition.x ~= safeX
            or characterPosition.z ~= safeZ

        if playerRecoveryCooldownTimer > 0 then
            playerRecoveryCooldownTimer = math.max(0, playerRecoveryCooldownTimer - deltaTime)
        end

        if isOutside then
            local edgePosition = Vector3(
                safeX,
                math.max(characterPosition.y, iceTopY + 0.25),
                safeZ
            )

            local moved = pcall(function()
                character.transform:ChangePosition(edgePosition)
            end)
            if not moved then
                character.transform.position = edgePosition
                pcall(function()
                    character.transform:SyncTransform()
                end)
            end

            pcall(function()
                character:SetVelocity(Vector3(0, 0, 0))
            end)
            pcall(function()
                character:SetAngularVelocity(Vector3(0, 0, 0))
            end)

            characterPosition = edgePosition
            isBelow = false
        end

        if playerRecoveryTimer <= 0 and isBelow then
            playerRecoveryTimer = playerRecoveryDuration
            playerRecoveryCooldownTimer = playerRecoveryCooldown
            playerRecoveryLogged = false

            local recoveryPosition = Vector3(
                icePosition.x,
                iceTopY + playerRecoveryHeight,
                icePosition.z
            )

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
        end

        if playerRecoveryTimer <= 0 then
            pcall(function()
                character:SetControlBlocked(false)
            end)
            pcall(function()
                character:SetIsOnIce(true)
            end)
            return
        end

        pcall(function()
            character:SetControlBlocked(true)
        end)
        pcall(function()
            character:SetVelocity(Vector3(0, 0, 0))
        end)
        pcall(function()
            character:SetAngularVelocity(Vector3(0, 0, 0))
        end)

        if not playerRecoveryLogged and scriptObject ~= nil then
            playerRecoveryLogged = true
            scriptObject:Log("[PlayerRecovery] Returned player to Ice_Cube.")
        end

        playerRecoveryTimer = playerRecoveryTimer - deltaTime
        if playerRecoveryTimer <= 0 then
            pcall(function()
                character:SetControlBlocked(false)
            end)
            pcall(function()
                character:CancelKnockBack()
            end)
        end
    end

    local function setUIObjectActive(uiObject, active)
        if uiObject == nil then return end

        pcall(function()
            uiObject:SetActive(active)
        end)
        pcall(function()
            uiObject.activeSelf = active
        end)
    end

    local function getTextComponent(uiObject)
        if uiObject == nil then return nil end

        local componentNames = {
            "TextMeshProUGUI",
            "TMP_Text",
            "TextMeshPro",
            "Text"
        }

        for i = 1, #componentNames do
            local ok, component = pcall(function()
                return uiObject:GetComponent(componentNames[i])
            end)

            if ok and component ~= nil then
                return component
            end
        end

        return nil
    end

    local function resolveTextObject(uiName)
        if serviceApi.uiService == nil then return nil end

        local uiObject = serviceApi.uiService:GetChildUI("IceGaugeHUD_UI/" .. uiName)
        if uiObject == nil then
            uiObject = serviceApi.uiService:FindByName(uiName)
        end

        return uiObject
    end

    local function resolveText(uiName)
        return getTextComponent(resolveTextObject(uiName))
    end

    local function setTextValue(uiObject, textComponent, value)
        local applied = false

        if textComponent ~= nil then
            local ok = pcall(function()
                textComponent.text = value
            end)
            applied = applied or ok
        end

        if uiObject ~= nil then
            local ok = pcall(function()
                uiObject.text = value
            end)
            applied = applied or ok
        end

        return applied
    end

    local function getComponentSafe(vObject, componentName)
        if vObject == nil then return nil end

        local ok, component = pcall(function()
            return vObject:GetComponent(componentName)
        end)

        if ok then return component end
        return nil
    end

    local function getComponentInChildrenSafe(vObject, componentName)
        if vObject == nil then return nil end

        local ok, component = pcall(function()
            return vObject:GetComponentInChildren(componentName)
        end)

        if ok then return component end
        return nil
    end

    local function resolveRaceHud()
        if raceTimerText == nil then
            raceTimerObject = resolveTextObject("RaceTimerText")
            raceTimerText = getTextComponent(raceTimerObject)
        end

        if raceStatusText == nil then
            raceStatusObject = resolveTextObject("RaceStatusText")
            raceStatusText = getTextComponent(raceStatusObject)
        end

        if iceCube == nil and serviceApi.world ~= nil then
            iceCube = serviceApi.world:GetVObject("Ice_Cube")
        end

        if finishLine == nil and serviceApi.world ~= nil then
            finishLine = serviceApi.world:GetVObject("Finish_Line")
        end

        if iceCollider == nil and iceCube ~= nil then
            iceCollider = getComponentSafe(iceCube, "Collider")
            if iceCollider == nil then
                iceCollider = getComponentInChildrenSafe(iceCube, "Collider")
            end
        end

        if icePlatformController == nil and iceCube ~= nil then
            icePlatformController = getComponentSafe(iceCube, "IceCubePlatformController")
        end

        if finishCollider == nil and finishLine ~= nil then
            finishCollider = getComponentSafe(finishLine, "Collider")
            if finishCollider == nil then
                finishCollider = getComponentInChildrenSafe(finishLine, "Collider")
            end
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
        if finishLine == nil or finishLine.transform == nil then return false end

        if iceCube ~= nil and iceCube.transform ~= nil
            and iceCollider ~= nil and finishCollider ~= nil then
            local ok, overlapping = pcall(function()
                return boundsOverlap(iceCollider.bounds, finishCollider.bounds)
            end)
            if ok and overlapping then return true end
        end

        local finishPosition = finishLine.transform.position
        if iceCube ~= nil and iceCube.transform ~= nil then
            local icePosition = iceCube.transform.position
            local dx = icePosition.x - finishPosition.x
            local dz = icePosition.z - finishPosition.z
            if dx * dx + dz * dz <= 100 then
                return true
            end
        end

        local character = resolveLocalCharacter()
        if character ~= nil and character.transform ~= nil then
            local characterPosition = character.transform.position
            local dx = characterPosition.x - finishPosition.x
            local dz = characterPosition.z - finishPosition.z
            if dx * dx + dz * dz <= 100 then
                return true
            end
        end

        return false
    end

    local function stopGameplay()
        if icePlatformController ~= nil then
            pcall(function()
                icePlatformController:SetPaused(true)
            end)
        end

        forEachPlayerCharacter(function(character)
            pcall(function()
                character:SetControlBlocked(true)
            end)
            pcall(function()
                character:SetVelocity(Vector3(0, 0, 0))
            end)
            pcall(function()
                character:SetAngularVelocity(Vector3(0, 0, 0))
            end)
        end)
    end

    local function resolveFeedbackObjects()
        if serviceApi == nil or serviceApi.world == nil then
            return
        end

        if startFeedback == nil then
            startFeedback = serviceApi.world:GetVObject("Feedback_START")
        end
        if goalFeedback == nil then
            goalFeedback = serviceApi.world:GetVObject("Feedback_GOAL")
        end
        if failFeedback == nil then
            failFeedback = serviceApi.world:GetVObject("Feedback_FAIL")
        end
    end

    local function playFeedback(feedback, message)
        if feedback == nil then
            resolveFeedbackObjects()
            if message == "START" then
                feedback = startFeedback
            elseif message == "GOAL" then
                feedback = goalFeedback
            else
                feedback = failFeedback
            end
        end
        if feedback == nil then return end

        local targetPosition
        if iceCube ~= nil and iceCube.transform ~= nil then
            local icePosition = iceCube.transform.position
            targetPosition = Vector3(icePosition.x, icePosition.y + 1.5, icePosition.z)
        else
            local character = resolveLocalCharacter()
            if character ~= nil and character.transform ~= nil then
                targetPosition = character.transform.position
            end
        end

        if targetPosition ~= nil and feedback.transform ~= nil then
            local moved = pcall(function()
                feedback.transform:ChangePosition(targetPosition)
            end)
            if not moved then
                feedback.transform.position = targetPosition
                pcall(function()
                    feedback.transform:SyncTransform()
                end)
            end
        end

        local okAudio, audioSource = pcall(function()
            return feedback:GetComponent("AudioSource")
        end)
        if okAudio and audioSource ~= nil then
            pcall(function()
                audioSource:Play()
            end)
        end

        local okParticles, particles = pcall(function()
            return feedback:GetComponentsInChildren("ParticleSystem")
        end)
        if okParticles and particles ~= nil then
            for i = 1, #particles do
                pcall(function()
                    particles[i]:Play(true)
                end)
            end
        end

        statusPulseTimer = 0.5
        if scriptObject ~= nil then
            scriptObject:Log("[GameFeedback] Played " .. message .. ".")
        end
    end

    local function updateStatusPulse(deltaTime)
        if raceStatusObject == nil or raceStatusObject.transform == nil then
            return
        end

        local transform = raceStatusObject.transform
        if statusPulseScale == nil then
            local scale = transform.localScale
            statusPulseScale = Vector3(scale.x, scale.y, scale.z)
        end

        if statusPulseTimer <= 0 then
            return
        end

        statusPulseTimer = math.max(0, statusPulseTimer - (deltaTime or 0))
        local progress = 1 - statusPulseTimer / 0.5
        local pulse = math.sin(progress * math.pi) * 0.3
        transform.localScale = Vector3(
            statusPulseScale.x * (1 + pulse),
            statusPulseScale.y * (1 + pulse),
            statusPulseScale.z
        )
        if statusPulseTimer <= 0 then
            transform.localScale = statusPulseScale
        end
        pcall(function()
            transform:SyncTransform()
        end)
    end

    local function finishRace(state, message)
        if raceEnded then return end

        raceEnded = true
        raceState = state
        setUIObjectActive(raceStatusObject, true)

        if scriptObject ~= nil then
            scriptObject:Log("[RaceHUD] Race finished: " .. message)
        end

        if not setTextValue(raceStatusObject, raceStatusText, message)
            and scriptObject ~= nil then
            scriptObject:Log("[RaceHUD] Could not find RaceStatusText component for " .. message .. ".")
        end

        if state == "goal" then
            playFeedback(goalFeedback, message)
        else
            playFeedback(failFeedback, message)
        end

        stopGameplay()
    end

    local function updateRaceHud(deltaTime)
        resolveRaceHud()

        if raceState == "running" then
            local elapsed = deltaTime or 0
            if startMessageRemaining > 0 then
                startMessageRemaining = math.max(0, startMessageRemaining - elapsed)
            else
                raceTimeRemaining = math.max(0, raceTimeRemaining - elapsed)
            end

            if hasReachedFinish() then
                finishRace("goal", "GOAL")
            elseif iceCube ~= nil and iceCube.transform ~= nil
                and iceCube.transform.localScale.y <= 0.01 then
                finishRace("gameover", "GAME OVER")
            elseif startMessageRemaining <= 0 and raceTimeRemaining <= 0 then
                finishRace("timeout", "TIME OVER")
            elseif raceStatusText ~= nil then
                if startMessageRemaining > 0 then
                    setUIObjectActive(raceStatusObject, true)
                    setTextValue(raceStatusObject, raceStatusText, "START!")
                    if not startFeedbackPlayed then
                        resolveFeedbackObjects()
                        startFeedbackPlayed = true
                        playFeedback(startFeedback, "START")
                    end
                else
                    setTextValue(raceStatusObject, raceStatusText, "")
                end
            end
        end

        setTextValue(raceTimerObject, raceTimerText, formatRaceTime(raceTimeRemaining))
        updateStatusPulse(deltaTime)
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
        pcall(function()
            Time.timeScale = 1
        end)

        _transform = scriptObject.parent.transform
        _camera = serviceApi.cameraService:GetGameCamera()
        resolveIceGauge()
        resolveRaceHud()
        resolveFeedbackObjects()
        scriptObject:Log("[PlayerRecovery] Recovery controller ready.")

        raceTimeRemaining = raceDuration
        setTextValue(raceTimerObject, raceTimerText, "02:30")
        setTextValue(raceStatusObject, raceStatusText, "START!")

        if this.UseLocalPlayer and playerService ~= nil then
            playerService.OnCreateCharacter:AddListener(onCreateCharacter)
            playerService.OnDestroyCharacter:AddListener(OnDestroyCharacter)
        end
    end
    
    
    function this.OnUpdate(deltaTime)
        updateIceGauge(deltaTime)
        updateRaceHud(deltaTime)
        if raceEnded then return end

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
            playerService.OnDestroyCharacter:RemoveListener(OnDestroyCharacter)
        end
    end

    __EX_FUNCTION__(this, __EX_VARIABLE__.vobject())
    function this.SetTarget(target)        
        this.Target = target
        blockUpdate = false
    end

