local this = __CREATOR__.new()

this.IceCube = __EX_VARIABLE__.vobject()
this.TargetCharacter = __EX_VARIABLE__.vobject()
this.UseLocalPlayer = __EX_VARIABLE__.bool(true)
this.EnableMultiplayerControl = __EX_VARIABLE__.bool(true)
this.MaxControllingPlayers = __EX_VARIABLE__.float(4)
this.PlayerSpeedBonus = __EX_VARIABLE__.float(30.0)

this.ControlDeadZone = __EX_VARIABLE__.float(0.25)
this.ControlStrength = __EX_VARIABLE__.float(9.0)
this.MaxMoveSpeed = __EX_VARIABLE__.float(34.0)
this.PlayerInfluenceRadiusScale = __EX_VARIABLE__.float(0.65)
this.PlayerInfluenceWeight = __EX_VARIABLE__.float(0.8)
this.MoveInputSmoothing = __EX_VARIABLE__.float(7.0)
this.MoveAcceleration = __EX_VARIABLE__.float(70.0)
this.SlideDeceleration = __EX_VARIABLE__.float(1.2)

this.MeltRate = __EX_VARIABLE__.float(0.035)
this.MinHeight = __EX_VARIABLE__.float(0.05)
this.ImpactDamage = __EX_VARIABLE__.float(0.18)
this.ImpactSpeedDamageScale = __EX_VARIABLE__.float(0.02)
this.DamageAnyCollision = __EX_VARIABLE__.bool(false)
this.BlockOnObstacle = __EX_VARIABLE__.bool(true)
this.CollisionStopTime = __EX_VARIABLE__.float(0.18)
this.DamageCooldown = __EX_VARIABLE__.float(0.35)
this.UseRigidbodyMove = __EX_VARIABLE__.bool(true)
this.PushBackSpeed = __EX_VARIABLE__.float(3.5)
this.PushBackDuration = __EX_VARIABLE__.float(0.18)
this.PushBackForce = __EX_VARIABLE__.float(2.5)
this.KeepGrounded = __EX_VARIABLE__.bool(true)
this.ClearVerticalVelocity = __EX_VARIABLE__.bool(true)
this.ClearAngularVelocity = __EX_VARIABLE__.bool(true)
this.KeepPlayersOnIce = __EX_VARIABLE__.bool(true)
this.ClampPlayersInsideIce = __EX_VARIABLE__.bool(true)
this.PreventPlayerEdgeFall = __EX_VARIABLE__.bool(true)
this.PlayerClampMargin = __EX_VARIABLE__.float(-0.1)
this.PlayerEdgeBuffer = __EX_VARIABLE__.float(0.35)
this.PlayerRecoverHeight = __EX_VARIABLE__.float(1.2)
this.PlayerRecoverBelowDepth = __EX_VARIABLE__.float(1.4)

this.ObstacleNamePrefix = __EX_VARIABLE__.string("Obstacle")
this.FinishName = __EX_VARIABLE__.string("Finish_Line")
this.EnableDropPlatforms = __EX_VARIABLE__.bool(true)
this.DropPlatformPrefix = __EX_VARIABLE__.string("Drop_")
this.DropPlatformRootName = __EX_VARIABLE__.string("Start_Platform")
this.DropShakeDuration = __EX_VARIABLE__.float(1.0)
this.DropShakeAmount = __EX_VARIABLE__.float(0.18)
this.DropShakeFrequency = __EX_VARIABLE__.float(24.0)
this.DropAcceleration = __EX_VARIABLE__.float(18.0)
this.DropMaxSpeed = __EX_VARIABLE__.float(20.0)
this.DropDistance = __EX_VARIABLE__.float(30.0)
this.DropDetectionDepth = __EX_VARIABLE__.float(3.0)
this.DropDetectionWidthScale = __EX_VARIABLE__.float(0.8)

this.EnableIceBallRain = __EX_VARIABLE__.bool(true)
this.IceBallPlatformName = __EX_VARIABLE__.string("Snow_Platform (2)")
this.IceBallObjectName = __EX_VARIABLE__.string("Ice_Ball_Hazard")
this.IceBallShadowName = __EX_VARIABLE__.string("Ice_Ball_Shadow")
this.IceBallIntervalMin = __EX_VARIABLE__.float(0.25)
this.IceBallIntervalMax = __EX_VARIABLE__.float(0.65)
this.IceBallWarningTime = __EX_VARIABLE__.float(1.0)
this.IceBallFallHeight = __EX_VARIABLE__.float(18.0)
this.IceBallFallAcceleration = __EX_VARIABLE__.float(65.0)
this.IceBallMaxFallSpeed = __EX_VARIABLE__.float(40.0)
this.IceBallRadius = __EX_VARIABLE__.float(5.0)
this.IceBallLandingOffset = __EX_VARIABLE__.float(-0.5)
this.IceBallAreaMargin = __EX_VARIABLE__.float(2.0)
this.IceBallImpactRadius = __EX_VARIABLE__.float(7.0)
this.IceBallImpactForce = __EX_VARIABLE__.float(9.0)
this.IceBallImpactDamage = __EX_VARIABLE__.float(0.22)
this.IceBallBreakDuration = __EX_VARIABLE__.float(0.4)

this.OnIceMelted = __EX_VARIABLE__.event()
this.OnFinishReached = __EX_VARIABLE__.event()
this.OnIceDamaged = __EX_VARIABLE__.event("float damage", "float height")

local serviceApi
local scriptObject
local playerService
local physicsService
local iceTransform
local iceRigidbody
local startScale
local bottomY = 0
local currentHeight = 0
local isFinished = false
local isPaused = false
local targetLogTime = 0
local collisionStopTimer = 0
local damageCooldownTimer = 0
local pushBackTimer = 0
-- Vector3 is available only after the runtime context is initialized.
local pushBackVelocity
local smoothedMoveX = 0
local smoothedMoveZ = 0
local fallbackVelocityX = 0
local fallbackVelocityZ = 0
local dropPlatformStates = {}
local controllingCharacters = {}
local speedBoostedCharacters = {}
local iceBallPlatform
local iceBallObject
local iceBallShadow
local iceBallState = "waiting"
local iceBallTimer = 0.5
local iceBallFallSpeed = 0
local iceBallSurfaceY = 0
local iceBallTargetPosition
local iceBallStartScale
local iceBallShadowScale
local iceBallCellStates = {}
local iceBallHitPlayer = false
local iceBallMissingLogTimer = 0
local impactFeedback
local impactFeedbackCooldown = 0

local function tryGet(target, key)
    if target == nil then
        return nil
    end

    local ok, value = pcall(function()
        return target[key]
    end)

    if ok then
        return value
    end

    return nil
end

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function startsWith(value, prefix)
    if value == nil or prefix == nil or prefix == "" then
        return false
    end

    return string.sub(value, 1, string.len(prefix)) == prefix
end

local function getVObjectName(vObject)
    if vObject == nil then return "" end
    local name = tryGet(vObject, "name")
    if name ~= nil then return name end
    return ""
end

local function getParentVObject(vObject)
    if vObject == nil then
        return nil
    end

    local parent = tryGet(vObject, "parent")
    if parent ~= nil then
        return parent
    end

    local transform = tryGet(vObject, "transform")
    local parentTransform = tryGet(transform, "parent")
    return tryGet(parentTransform, "vObject")
end

local function isObstacleVObject(vObject)
    local current = vObject

    for _ = 1, 8 do
        if current == nil then
            return false
        end

        if startsWith(getVObjectName(current), this.ObstacleNamePrefix) then
            return true
        end

        current = getParentVObject(current)
    end

    return false
end

local function isNamedOrChildOf(vObject, targetName)
    local current = vObject

    for _ = 1, 12 do
        if current == nil then
            return false
        end

        if getVObjectName(current) == targetName then
            return true
        end

        current = getParentVObject(current)
    end

    return false
end

local function findDropPlatform(vObject)
    local current = vObject

    for _ = 1, 12 do
        if current == nil then
            return nil
        end

        local name = getVObjectName(current)
        if startsWith(name, this.DropPlatformPrefix) then
            return current
        end

        current = getParentVObject(current)
    end

    return nil
end

local function startDropPlatform(vObject)
    if this.EnableDropPlatforms ~= true or vObject == nil then
        return
    end

    local platform = findDropPlatform(vObject)
    if platform == nil or dropPlatformStates[platform] ~= nil then
        return
    end

    local platformTransform = tryGet(platform, "transform")
    if platformTransform == nil then
        return
    end

    local position = platformTransform.localPosition
    dropPlatformStates[platform] = {
        transform = platformTransform,
        origin = Vector3(position.x, position.y, position.z),
        elapsed = 0,
        fallSpeed = 0,
        fallDistance = 0,
        falling = false,
        finished = false
    }
end

local function updateDropPlatforms(deltaTime)
    for _, state in pairs(dropPlatformStates) do
        if not state.finished then
            state.elapsed = state.elapsed + deltaTime

            if not state.falling then
                if state.elapsed >= this.DropShakeDuration then
                    state.falling = true
                    state.transform.localPosition = state.origin
                    state.transform:SyncTransform()
                else
                    local phase = state.elapsed * this.DropShakeFrequency
                    local offsetX = math.sin(phase) * this.DropShakeAmount
                    local offsetZ = math.sin(phase * 1.37) * this.DropShakeAmount
                    state.transform.localPosition = Vector3(
                        state.origin.x + offsetX,
                        state.origin.y,
                        state.origin.z + offsetZ
                    )
                    state.transform:SyncTransform()
                end
            else
                state.fallSpeed = math.min(
                    state.fallSpeed + this.DropAcceleration * deltaTime,
                    this.DropMaxSpeed
                )

                local fallStep = state.fallSpeed * deltaTime
                state.fallDistance = state.fallDistance + fallStep
                state.transform.localPosition = Vector3(
                    state.origin.x,
                    state.origin.y - state.fallDistance,
                    state.origin.z
                )
                state.transform:SyncTransform()

                if state.fallDistance >= this.DropDistance then
                    state.finished = true
                end
            end
        end
    end
end

local function detectDropPlatformBelow()
    if this.EnableDropPlatforms ~= true or physicsService == nil or iceTransform == nil then
        return
    end

    local depth = this.DropDetectionDepth or 3.0
    local widthScale = this.DropDetectionWidthScale or 0.8
    local scale = iceTransform.localScale
    local icePosition = iceTransform.position
    local center = Vector3(
        icePosition.x,
        icePosition.y - depth * 0.5,
        icePosition.z
    )
    local halfExtents = Vector3(
        math.max(scale.x * widthScale, 0.5),
        depth * 0.5,
        math.max(scale.z * widthScale, 0.5)
    )

    local ok, colliders = pcall(function()
        return physicsService:OverlapBox(center, halfExtents, Quaternion.identity)
    end)

    if not ok or colliders == nil then
        return
    end

    local closestPlatform = nil
    local closestDistance = math.huge

    for i = 1, #colliders do
        local platform = findDropPlatform(colliders[i].vObject)
        if platform ~= nil and dropPlatformStates[platform] == nil then
            local platformTransform = tryGet(platform, "transform")
            if platformTransform ~= nil then
                local platformPosition = platformTransform.position
                local dx = platformPosition.x - icePosition.x
                local dz = platformPosition.z - icePosition.z
                local distance = dx * dx + dz * dz

                if distance < closestDistance then
                    closestDistance = distance
                    closestPlatform = platform
                end
            end
        end
    end

    startDropPlatform(closestPlatform)
end

local function callEvent(eventObject, ...)
    if eventObject ~= nil then
        eventObject:Call(...)
    end
end

local function getScriptEvent(eventName)
    if scriptObject == nil then
        return nil
    end

    return tryGet(scriptObject, eventName)
end

local function syncTransformPosition(transform, position)
    if transform == nil then return end

    local changePosition = tryGet(transform, "ChangePosition")
    if changePosition ~= nil then
        changePosition(transform, position)
    else
        transform.position = position
        local syncTransform = tryGet(transform, "SyncTransform")
        if syncTransform ~= nil then
            syncTransform(transform)
        end
    end
end

local function syncTransformScale(transform, scale)
    if transform == nil then return end

    local changeLocalScale = tryGet(transform, "ChangeLocalScale")
    if changeLocalScale ~= nil then
        changeLocalScale(transform, scale)
    else
        transform.localScale = scale
        local syncTransform = tryGet(transform, "SyncTransform")
        if syncTransform ~= nil then
            syncTransform(transform)
        end
    end
end

local function resolveIceCube()
    if this.IceCube ~= nil then
        return this.IceCube
    end

    if scriptObject ~= nil and scriptObject.parent ~= nil and getVObjectName(scriptObject.parent) == "Ice_Cube" then
        this.IceCube = scriptObject.parent
        return this.IceCube
    end

    if serviceApi ~= nil and serviceApi.world ~= nil then
        this.IceCube = serviceApi.world:GetVObject("Ice_Cube")
    end

    return this.IceCube
end

local function setTargetFromPlayer(player)
    if player == nil or player.character == nil then return end

    local character = player.character
    if speedBoostedCharacters[character] == nil then
        local setMaxVelocityBonus = tryGet(character, "SetMaxVelocityBonus")
        if setMaxVelocityBonus ~= nil and this.PlayerSpeedBonus > 0 then
            setMaxVelocityBonus(character, this.PlayerSpeedBonus)
            speedBoostedCharacters[character] = true
        end
    end

    if this.UseLocalPlayer then
        if player.isLocalPlayer then
            this.TargetCharacter = character
        end
    elseif this.TargetCharacter == nil then
        this.TargetCharacter = character
    end
end

local function addControllingCharacter(character)
    if character == nil or tryGet(character, "transform") == nil then
        return false
    end

    for i = 1, #controllingCharacters do
        if controllingCharacters[i] == character then
            return false
        end
    end

    local maxPlayers = math.max(math.floor(this.MaxControllingPlayers or 4), 1)
    if #controllingCharacters >= maxPlayers then
        return false
    end

    controllingCharacters[#controllingCharacters + 1] = character
    return true
end

local function refreshControllingCharacters()
    controllingCharacters = {}

    if playerService == nil then
        if this.TargetCharacter ~= nil then
            addControllingCharacter(this.TargetCharacter)
        end
        return #controllingCharacters
    end

    local getPlayers = tryGet(playerService, "GetPlayers")
    if getPlayers ~= nil then
        local ok, players = pcall(function()
            return getPlayers(playerService)
        end)

        if ok and players ~= nil then
            for i = 1, #players do
                local player = players[i]
                if player ~= nil and player.character ~= nil then
                    setTargetFromPlayer(player)
                    addControllingCharacter(player.character)
                end

                if #controllingCharacters >= math.max(math.floor(this.MaxControllingPlayers or 4), 1) then
                    break
                end
            end
        end
    end

    if #controllingCharacters == 0 then
        local localPlayer = tryGet(playerService, "localPlayer")
        if localPlayer ~= nil and localPlayer.character ~= nil then
            setTargetFromPlayer(localPlayer)
            addControllingCharacter(localPlayer.character)
        end
    end

    if #controllingCharacters == 0 and this.TargetCharacter ~= nil then
        addControllingCharacter(this.TargetCharacter)
    end

    return #controllingCharacters
end

local function clearTargetFromPlayer(player)
    if player == nil then return end
    if player.character == this.TargetCharacter then
        this.TargetCharacter = nil
    end
end

local function acquireTargetCharacter()
    if this.TargetCharacter ~= nil and tryGet(this.TargetCharacter, "transform") ~= nil then
        return true
    end

    if playerService == nil then
        return false
    end

    local localPlayer = tryGet(playerService, "localPlayer")
    if localPlayer ~= nil and localPlayer.character ~= nil then
        setTargetFromPlayer(localPlayer)
        if this.TargetCharacter ~= nil then
            return true
        end
    end

    local getPlayers = tryGet(playerService, "GetPlayers")
    if getPlayers ~= nil then
        local ok, players = pcall(function()
            return getPlayers(playerService)
        end)

        if ok and players ~= nil then
            local firstCharacter = nil

            for i = 1, #players do
                local player = players[i]
                if player ~= nil and player.character ~= nil then
                    if firstCharacter == nil then
                        firstCharacter = player.character
                    end

                    setTargetFromPlayer(player)
                    if this.TargetCharacter ~= nil then
                        return true
                    end
                end
            end

            if firstCharacter ~= nil then
                this.TargetCharacter = firstCharacter
                return true
            end
        end
    end

    return false
end

local function isCharacterOnIce(character, icePosition)
    if character == nil or character.transform == nil or iceTransform == nil then
        return false
    end

    local characterPosition = character.transform.position
    local iceScale = iceTransform.localScale
    local halfX = math.abs(iceScale.x) * 0.5 + 0.75
    local halfZ = math.abs(iceScale.z) * 0.5 + 0.75
    local iceTopY = icePosition.y + math.abs(iceScale.y) * 0.5

    if math.abs(characterPosition.x - icePosition.x) > halfX then
        return false
    end

    if math.abs(characterPosition.z - icePosition.z) > halfZ then
        return false
    end

    return characterPosition.y >= iceTopY - 1.25 and characterPosition.y <= iceTopY + 3.0
end

local function calculateMultiplayerMove(icePosition)
    local count = refreshControllingCharacters()
    if count <= 0 then
        return nil, nil, 0
    end

    local moveX = 0
    local moveZ = 0
    local contributors = 0
    local influenceRadiusScale = this.PlayerInfluenceRadiusScale or 0.65
    local weight = this.PlayerInfluenceWeight or 1.0

    for i = 1, #controllingCharacters do
        local character = controllingCharacters[i]
        if isCharacterOnIce(character, icePosition) then
            local position = character.transform.position
            local offsetX = position.x - icePosition.x
            local offsetZ = position.z - icePosition.z

            local influenceX = offsetX * this.ControlStrength * weight
            local influenceZ = offsetZ * this.ControlStrength * weight

            local radiusX = math.max(math.abs(iceTransform.localScale.x) * influenceRadiusScale, this.ControlDeadZone)
            local radiusZ = math.max(math.abs(iceTransform.localScale.z) * influenceRadiusScale, this.ControlDeadZone)

            if math.abs(offsetX) <= this.ControlDeadZone then
                influenceX = 0
            else
                influenceX = influenceX * clamp(math.abs(offsetX) / radiusX, 0.25, 1.0)
            end

            if math.abs(offsetZ) <= this.ControlDeadZone then
                influenceZ = 0
            else
                influenceZ = influenceZ * clamp(math.abs(offsetZ) / radiusZ, 0.25, 1.0)
            end

            moveX = moveX + influenceX
            moveZ = moveZ + influenceZ
            contributors = contributors + 1
        end
    end

    if contributors <= 0 then
        return nil, nil, 0
    end

    return moveX / contributors, moveZ / contributors, contributors
end

local function stopCharacterMotion(character)
    pcall(function()
        character:SetVelocity(Vector3(0, 0, 0))
    end)
    pcall(function()
        character:SetAngularVelocity(Vector3(0, 0, 0))
    end)
end

local function moveCharacterTo(character, position)
    if character == nil or character.transform == nil then
        return
    end

    local moved = pcall(function()
        character.transform:ChangePosition(position)
    end)

    if not moved then
        character.transform.position = position
        pcall(function()
            character.transform:SyncTransform()
        end)
    end
end

local function keepPlayersOnIceTop()
    if this.KeepPlayersOnIce ~= true or iceTransform == nil then
        return
    end

    refreshControllingCharacters()

    local icePosition = iceTransform.position
    local iceScale = iceTransform.localScale
    local margin = this.PlayerClampMargin or -0.1
    local halfX = math.max(math.abs(iceScale.x) * 0.5 - margin, 0.25)
    local halfZ = math.max(math.abs(iceScale.z) * 0.5 - margin, 0.25)
    local edgeBuffer = math.max(this.PlayerEdgeBuffer or 0.35, 0)
    local outerHalfX = math.abs(iceScale.x) * 0.5 + edgeBuffer
    local outerHalfZ = math.abs(iceScale.z) * 0.5 + edgeBuffer
    local iceTopY = icePosition.y + math.abs(iceScale.y) * 0.5
    local recoverY = iceTopY + math.max(this.PlayerRecoverHeight or 1.1, 0.2)
    local belowDepth = math.max(this.PlayerRecoverBelowDepth or 1.4, 0.1)

    for i = 1, #controllingCharacters do
        local character = controllingCharacters[i]
        if character ~= nil and character.transform ~= nil then
            local position = character.transform.position
            local clampedX = clamp(position.x, icePosition.x - halfX, icePosition.x + halfX)
            local clampedZ = clamp(position.z, icePosition.z - halfZ, icePosition.z + halfZ)
            local targetY = position.y
            local shouldMove = false

            if this.ClampPlayersInsideIce == true
                and (position.x ~= clampedX or position.z ~= clampedZ) then
                shouldMove = true
            end

            local isNearTop = position.y >= iceTopY - belowDepth
                and position.y <= iceTopY + 3.0
            local crossedOuterEdge = math.abs(position.x - icePosition.x) > outerHalfX
                or math.abs(position.z - icePosition.z) > outerHalfZ

            if this.PreventPlayerEdgeFall == true
                and isNearTop
                and crossedOuterEdge then
                shouldMove = true
            end

            if position.y < iceTopY - belowDepth then
                targetY = recoverY
                shouldMove = true
                clampedX = clamp(position.x, icePosition.x - halfX, icePosition.x + halfX)
                clampedZ = clamp(position.z, icePosition.z - halfZ, icePosition.z + halfZ)
            end

            if shouldMove then
                moveCharacterTo(character, Vector3(clampedX, targetY, clampedZ))
                stopCharacterMotion(character)
            end
        end
    end
end

local function tryAssignCharacterFromVObject(vObject)
    if vObject == nil then
        return false
    end

    local cast = tryGet(vObject, "Cast")
    if cast == nil then
        return false
    end

    local ok, character = pcall(function()
        return cast(vObject, "Character")
    end)

    if ok and character ~= nil then
        this.TargetCharacter = character
        return true
    end

    return false
end

local function getGroundedY()
    return bottomY + currentHeight * 0.5
end

local function keepIceGrounded(position)
    if this.KeepGrounded ~= true or iceTransform == nil then
        return position
    end

    if position == nil then
        position = iceTransform.position
    end

    position.y = getGroundedY()

    if iceRigidbody ~= nil then
        if this.ClearVerticalVelocity == true then
            local velocity = tryGet(iceRigidbody, "velocity")
            if velocity ~= nil then
                velocity.y = 0
                pcall(function()
                    iceRigidbody.velocity = velocity
                end)
            end
        end

        if this.ClearAngularVelocity == true then
            pcall(function()
                iceRigidbody.angularVelocity = Vector3(0, 0, 0)
            end)
        end
    end

    return position
end

local function applyHeight()
    if iceTransform == nil or startScale == nil then return end

    currentHeight = clamp(currentHeight, 0, startScale.y)
    local meltedNow = currentHeight <= this.MinHeight
    if meltedNow then
        currentHeight = 0
    end

    local scale = iceTransform.localScale
    scale.x = startScale.x
    scale.y = currentHeight
    scale.z = startScale.z
    syncTransformScale(iceTransform, scale)

    local position = iceTransform.position
    position = keepIceGrounded(position)
    syncTransformPosition(iceTransform, position)

    if meltedNow and not isFinished then
        isFinished = true
        callEvent(getScriptEvent("OnIceMelted"))
        if scriptObject ~= nil then
            scriptObject:Log("Ice_Cube melted before reaching the finish.")
        end
    end
end

local function playImpactFeedback()
    if impactFeedbackCooldown > 0 or serviceApi == nil or serviceApi.world == nil then
        return
    end

    if impactFeedback == nil then
        impactFeedback = serviceApi.world:GetVObject("Feedback_IMPACT")
    end
    if impactFeedback == nil then return end

    if impactFeedback.transform ~= nil and iceTransform ~= nil then
        local icePosition = iceTransform.position
        local effectPosition = Vector3(
            icePosition.x,
            icePosition.y + math.max(currentHeight * 0.5, 0.2),
            icePosition.z
        )
        local moved = pcall(function()
            impactFeedback.transform:ChangePosition(effectPosition)
        end)
        if not moved then
            impactFeedback.transform.position = effectPosition
            pcall(function()
                impactFeedback.transform:SyncTransform()
            end)
        end
    end

    local okAudio, audioSource = pcall(function()
        return impactFeedback:GetComponent("AudioSource")
    end)
    if okAudio and audioSource ~= nil then
        pcall(function()
            audioSource.pitch = 0.92 + math.random() * 0.16
            audioSource:Play()
        end)
    end

    local okParticles, particles = pcall(function()
        return impactFeedback:GetComponentsInChildren("ParticleSystem")
    end)
    if okParticles and particles ~= nil then
        for i = 1, #particles do
            pcall(function()
                particles[i]:Play(true)
            end)
        end
    end

    impactFeedbackCooldown = 0.25
    if scriptObject ~= nil then
        scriptObject:Log("[GameFeedback] Played IMPACT.")
    end
end

local function damageIce(amount)
    if isFinished or isPaused then return end
    if amount == nil or amount <= 0 then return end

    currentHeight = currentHeight - amount
    applyHeight()
    callEvent(getScriptEvent("OnIceDamaged"), amount, currentHeight)
    playImpactFeedback()
end

local function getVectorMagnitude(vector)
    if vector == nil then return 0 end

    local x = vector.x or 0
    local y = vector.y or 0
    local z = vector.z or 0
    return math.sqrt(x * x + y * y + z * z)
end

local function getComponent(vObject, componentName)
    if vObject == nil then
        return nil
    end

    local ok, component = pcall(function()
        return vObject:GetComponent(componentName)
    end)

    if ok then
        return component
    end

    return nil
end

local function setVObjectActive(vObject, active)
    if vObject == nil then return end

    pcall(function()
        vObject:SetActive(active)
    end)
end

local function randomRange(minValue, maxValue)
    if maxValue < minValue then
        minValue, maxValue = maxValue, minValue
    end

    return minValue + (maxValue - minValue) * math.random()
end

local function collectIceBallCells()
    if iceBallObject == nil or #iceBallCellStates > 0 then
        return
    end

    local ok, renderers = pcall(function()
        return iceBallObject:GetComponentsInChildren("Renderer")
    end)

    if not ok or renderers == nil then
        return
    end

    for i = 1, #renderers do
        local renderer = renderers[i]
        local transform = tryGet(renderer, "transform")
        local name = tryGet(transform, "name")

        if transform ~= nil and startsWith(name, "Sphere_cell") then
            local originPosition = transform.localPosition
            local originRotation = transform.localRotation
            local originScale = transform.localScale
            local direction = Vector3(originPosition.x, math.abs(originPosition.y) + 0.5, originPosition.z)
            local magnitude = math.sqrt(
                direction.x * direction.x
                + direction.y * direction.y
                + direction.z * direction.z
            )

            if magnitude <= 0.001 then
                direction = Vector3(randomRange(-1, 1), randomRange(0.3, 1), randomRange(-1, 1))
                magnitude = math.max(math.sqrt(
                    direction.x * direction.x
                    + direction.y * direction.y
                    + direction.z * direction.z
                ), 0.001)
            end

            direction = Vector3(direction.x / magnitude, direction.y / magnitude, direction.z / magnitude)
            iceBallCellStates[#iceBallCellStates + 1] = {
                transform = transform,
                originPosition = Vector3(originPosition.x, originPosition.y, originPosition.z),
                originRotation = originRotation,
                originScale = Vector3(originScale.x, originScale.y, originScale.z),
                direction = direction
            }
        end
    end
end

local function resetIceBallCells()
    collectIceBallCells()

    for i = 1, #iceBallCellStates do
        local state = iceBallCellStates[i]
        local transform = state.transform
        if transform ~= nil then
            transform.localPosition = state.originPosition
            transform.localRotation = state.originRotation
            transform.localScale = state.originScale
            pcall(function()
                transform:SyncTransform()
            end)
        end
    end
end

local function updateIceBallBreakCells(progress)
    collectIceBallCells()

    local t = clamp(progress, 0, 1)
    local eased = 1 - (1 - t) * (1 - t)

    for i = 1, #iceBallCellStates do
        local state = iceBallCellStates[i]
        local transform = state.transform
        if transform ~= nil then
            local scatter = Vector3(
                state.direction.x * 3.2 * eased,
                state.direction.y * 3.2 * eased + math.sin(t * math.pi) * 1.2,
                state.direction.z * 3.2 * eased
            )
            transform.localPosition = Vector3(
                state.originPosition.x + scatter.x,
                state.originPosition.y + scatter.y,
                state.originPosition.z + scatter.z
            )
            transform.localScale = Vector3(
                state.originScale.x * (1 - t),
                state.originScale.y * (1 - t),
                state.originScale.z * (1 - t)
            )
            pcall(function()
                transform:SyncTransform()
            end)
        end
    end
end

local function resolveIceBallObjects()
    if serviceApi == nil or serviceApi.world == nil then
        return false
    end

    if iceBallPlatform == nil then
        iceBallPlatform = serviceApi.world:GetVObject(this.IceBallPlatformName)
    end
    if iceBallObject == nil then
        iceBallObject = serviceApi.world:GetVObject(this.IceBallObjectName)
    end
    if iceBallShadow == nil then
        iceBallShadow = serviceApi.world:GetVObject(this.IceBallShadowName)
    end

    return iceBallPlatform ~= nil
        and iceBallObject ~= nil
        and iceBallShadow ~= nil
        and iceBallPlatform.transform ~= nil
        and iceBallObject.transform ~= nil
        and iceBallShadow.transform ~= nil
end

local function getIceBallArea()
    if iceBallPlatform == nil or iceBallPlatform.transform == nil then
        return nil
    end

    local colliderNames = { "BoxCollider", "MeshCollider", "Collider" }
    for i = 1, #colliderNames do
        local collider = getComponent(iceBallPlatform, colliderNames[i])
        local bounds = tryGet(collider, "bounds")
        local center = tryGet(bounds, "center")
        local extents = tryGet(bounds, "extents")

        if center ~= nil and extents ~= nil then
            return center, extents
        end
    end

    local transform = iceBallPlatform.transform
    local position = transform.position
    local scale = transform.localScale
    return position, Vector3(
        math.abs(scale.x) * 0.5,
        math.max(math.abs(scale.y) * 0.5, 0.1),
        math.abs(scale.z) * 0.5
    )
end

local function hideIceBallHazard()
    setVObjectActive(iceBallObject, false)
    setVObjectActive(iceBallShadow, false)
end

local function scheduleNextIceBall()
    iceBallState = "waiting"
    iceBallTimer = randomRange(this.IceBallIntervalMin, this.IceBallIntervalMax)
    iceBallFallSpeed = 0
    iceBallHitPlayer = false
    resetIceBallCells()
    hideIceBallHazard()
end

local function beginIceBallWarning()
    local center, extents = getIceBallArea()
    if center == nil or extents == nil then
        scheduleNextIceBall()
        return
    end

    local margin = math.max(this.IceBallAreaMargin, 0)
    local radius = math.max(this.IceBallRadius, 0.1)
    local rangeX = math.max(extents.x - margin - radius, 0)
    local rangeZ = math.max(extents.z - margin - radius, 0)

    iceBallSurfaceY = center.y + extents.y
    iceBallTargetPosition = Vector3(
        center.x + randomRange(-rangeX, rangeX),
        iceBallSurfaceY,
        center.z + randomRange(-rangeZ, rangeZ)
    )

    local shadowTransform = iceBallShadow.transform
    iceBallShadowScale = shadowTransform.localScale
    syncTransformPosition(shadowTransform, Vector3(
        iceBallTargetPosition.x,
        iceBallSurfaceY + 0.04,
        iceBallTargetPosition.z
    ))
    syncTransformScale(shadowTransform, Vector3(
        iceBallShadowScale.x * 0.35,
        iceBallShadowScale.y,
        iceBallShadowScale.z * 0.35
    ))

    setVObjectActive(iceBallObject, false)
    setVObjectActive(iceBallShadow, true)
    iceBallState = "warning"
    iceBallTimer = math.max(this.IceBallWarningTime, 0.05)
end

local function beginIceBallFall()
    local ballTransform = iceBallObject.transform
    iceBallStartScale = ballTransform.localScale
    syncTransformScale(ballTransform, iceBallStartScale)
    syncTransformPosition(ballTransform, Vector3(
        iceBallTargetPosition.x,
        iceBallSurfaceY + this.IceBallFallHeight,
        iceBallTargetPosition.z
    ))

    setVObjectActive(iceBallShadow, false)
    setVObjectActive(iceBallObject, true)
    iceBallState = "falling"
    iceBallFallSpeed = 0
    iceBallHitPlayer = false
end

local function applyIceBallImpact()
    if iceTransform == nil then return end

    local icePosition = iceTransform.position
    local directionX = icePosition.x - iceBallTargetPosition.x
    local directionZ = icePosition.z - iceBallTargetPosition.z
    local magnitude = math.sqrt(directionX * directionX + directionZ * directionZ)

    if magnitude <= 0.001 then
        directionX = randomRange(-1, 1)
        directionZ = randomRange(-1, 1)
        magnitude = math.max(math.sqrt(directionX * directionX + directionZ * directionZ), 0.001)
    end

    directionX = directionX / magnitude
    directionZ = directionZ / magnitude
    pushBackVelocity = Vector3(
        directionX * this.IceBallImpactForce,
        0,
        directionZ * this.IceBallImpactForce
    )
    pushBackTimer = math.max(this.PushBackDuration, 0.25)
    collisionStopTimer = math.max(collisionStopTimer, 0.12)

    if iceRigidbody ~= nil then
        local force = Vector3(
            directionX * this.IceBallImpactForce,
            0,
            directionZ * this.IceBallImpactForce
        )
        local applied = false

        if VFramework ~= nil
            and VFramework.ForceMode ~= nil
            and VFramework.ForceMode.VelocityChange ~= nil then
            applied = pcall(function()
                iceRigidbody:AddForce(force, VFramework.ForceMode.VelocityChange)
            end)
        end

        if not applied then
            pcall(function()
                iceRigidbody:AddForce(force)
            end)
        end
    end

    damageIce(this.IceBallImpactDamage)
end

local function checkIceBallPlayerHit(ballPosition)
    if iceBallHitPlayer or not acquireTargetCharacter() then
        return
    end

    local targetTransform = tryGet(this.TargetCharacter, "transform")
    if targetTransform == nil then return end

    local targetPosition = targetTransform.position
    local dx = targetPosition.x - ballPosition.x
    local dy = targetPosition.y - (ballPosition.y + math.max(this.IceBallRadius, 0.1))
    local dz = targetPosition.z - ballPosition.z
    local radius = math.max(this.IceBallImpactRadius, 0.1)

    if dx * dx + dz * dz <= radius * radius
        and math.abs(dy) <= radius * 1.25 then
        iceBallHitPlayer = true
        applyIceBallImpact()
    end
end

local function checkIceBallIceCubeHit(ballPosition)
    if iceBallHitPlayer or iceTransform == nil then
        return false
    end

    local icePosition = iceTransform.position
    local iceScale = iceTransform.localScale
    local radius = math.max(this.IceBallRadius, 0.1)
    local halfX = math.abs(iceScale.x) * 0.5 + radius
    local halfZ = math.abs(iceScale.z) * 0.5 + radius
    local dx = math.abs(ballPosition.x - icePosition.x)
    local dz = math.abs(ballPosition.z - icePosition.z)

    if dx > halfX or dz > halfZ then
        return false
    end

    local iceTopY = icePosition.y + math.abs(iceScale.y) * 0.5
    if ballPosition.y > iceTopY + 0.05 then
        return false
    end

    iceBallHitPlayer = true
    iceBallTargetPosition = Vector3(ballPosition.x, ballPosition.y, ballPosition.z)
    applyIceBallImpact()
    return true
end

local function triggerIceBallBreakEffect()
    local breakEffect = getComponent(iceBallObject, "IceBallCellBreakEffect")
    if breakEffect == nil then
        return
    end

    pcall(function()
        breakEffect:BreakNow()
    end)
end

local function beginIceBallBreak()
    iceBallState = "breaking"
    iceBallTimer = math.max(this.IceBallBreakDuration, 0.05)
    setVObjectActive(iceBallShadow, false)
    triggerIceBallBreakEffect()
end

local function updateIceBallRain(deltaTime)
    if this.EnableIceBallRain ~= true or isPaused or isFinished then
        return
    end

    if not resolveIceBallObjects() then
        iceBallMissingLogTimer = iceBallMissingLogTimer + deltaTime
        if iceBallMissingLogTimer >= 5 then
            iceBallMissingLogTimer = 0
            if scriptObject ~= nil then
                scriptObject:Log(
                    "Ice ball rain is waiting for "
                    .. this.IceBallPlatformName .. ", "
                    .. this.IceBallObjectName .. " and "
                    .. this.IceBallShadowName .. "."
                )
            end
        end
        return
    end

    if iceBallState == "waiting" then
        iceBallTimer = iceBallTimer - deltaTime
        if iceBallTimer <= 0 then
            beginIceBallWarning()
        end
        return
    end

    if iceBallState == "warning" then
        iceBallTimer = iceBallTimer - deltaTime
        local warningDuration = math.max(this.IceBallWarningTime, 0.05)
        local progress = clamp(1 - iceBallTimer / warningDuration, 0, 1)
        local pulse = 0.9 + math.sin(progress * math.pi * 8) * 0.1
        local scale = 0.35 + progress * 0.65
        syncTransformScale(iceBallShadow.transform, Vector3(
            iceBallShadowScale.x * scale * pulse,
            iceBallShadowScale.y,
            iceBallShadowScale.z * scale * pulse
        ))

        if iceBallTimer <= 0 then
            beginIceBallFall()
        end
        return
    end

    if iceBallState == "falling" then
        iceBallFallSpeed = math.min(
            iceBallFallSpeed + this.IceBallFallAcceleration * deltaTime,
            this.IceBallMaxFallSpeed
        )

        local ballTransform = iceBallObject.transform
        local position = ballTransform.position
        position.x = iceBallTargetPosition.x
        position.z = iceBallTargetPosition.z
        position.y = position.y - iceBallFallSpeed * deltaTime
        local landingY = iceBallSurfaceY + this.IceBallLandingOffset

        if position.y <= landingY then
            position.y = landingY
        end

        syncTransformPosition(ballTransform, position)
        checkIceBallPlayerHit(position)
        if checkIceBallIceCubeHit(position) then
            beginIceBallBreak()
            return
        end

        if position.y <= landingY then
            beginIceBallBreak()
        end
        return
    end

    if iceBallState == "breaking" then
        iceBallTimer = iceBallTimer - deltaTime
        local breakDuration = math.max(this.IceBallBreakDuration, 0.05)
        updateIceBallBreakCells(1 - iceBallTimer / breakDuration)

        if iceBallTimer <= 0 then
            syncTransformScale(iceBallObject.transform, iceBallStartScale)
            scheduleNextIceBall()
        end
    end
end

local function moveIce(moveX, moveZ, deltaTime)
    if iceRigidbody ~= nil and this.UseRigidbodyMove == true then
        local velocity = tryGet(iceRigidbody, "velocity")
        if velocity == nil then
            velocity = Vector3(0, 0, 0)
        end

        local hasMoveInput = math.abs(moveX) > 0.001 or math.abs(moveZ) > 0.001
        local acceleration = hasMoveInput
            and (this.MoveAcceleration or 40.0)
            or (this.SlideDeceleration or 4.0)
        local targetVelocity = Vector3(moveX, 0, moveZ)
        local nextVelocity = Vector3.MoveTowards(
            velocity,
            targetVelocity,
            acceleration * deltaTime
        )
        nextVelocity.y = 0
        iceRigidbody.velocity = nextVelocity

        return
    end

    local hasMoveInput = math.abs(moveX) > 0.001 or math.abs(moveZ) > 0.001
    local response = hasMoveInput
        and (this.MoveAcceleration or 40.0)
        or (this.SlideDeceleration or 4.0)
    local blend = clamp(response * deltaTime, 0, 1)

    fallbackVelocityX = fallbackVelocityX + (moveX - fallbackVelocityX) * blend
    fallbackVelocityZ = fallbackVelocityZ + (moveZ - fallbackVelocityZ) * blend

    local position = iceTransform.position
    position.x = position.x + fallbackVelocityX * deltaTime
    position.z = position.z + fallbackVelocityZ * deltaTime
    syncTransformPosition(iceTransform, keepIceGrounded(position))
end

local function shouldDamageFromCollision(collision)
    if this.DamageAnyCollision then
        return true
    end

    if collision == nil then
        return false
    end

    return isObstacleVObject(collision.vObject)
end

local function getPushBackDirection(collision)
    if collision == nil or iceTransform == nil then
        return Vector3(0, 0, 0)
    end

    local icePos = iceTransform.position
    local hitTransform = tryGet(collision, "transform")
    local hitPos = nil

    if hitTransform ~= nil then
        hitPos = tryGet(hitTransform, "position")
    end

    local dirX = 0
    local dirZ = 0

    if hitPos ~= nil then
        dirX = icePos.x - hitPos.x
        dirZ = icePos.z - hitPos.z
    end

    local magnitude = math.sqrt(dirX * dirX + dirZ * dirZ)

    if magnitude <= 0.001 then
        local relativeVelocity = tryGet(collision, "relativeVelocity")
        if relativeVelocity ~= nil then
            dirX = -(relativeVelocity.x or 0)
            dirZ = -(relativeVelocity.z or 0)
            magnitude = math.sqrt(dirX * dirX + dirZ * dirZ)
        end
    end

    if magnitude <= 0.001 then
        return Vector3(0, 0, -1)
    end

    return Vector3(dirX / magnitude, 0, dirZ / magnitude)
end

local function pushBackFromObstacleCollision(collision)
    if this.BlockOnObstacle ~= true or iceTransform == nil then
        return
    end

    local direction = getPushBackDirection(collision)
    pushBackVelocity = Vector3(direction.x * this.PushBackSpeed, 0, direction.z * this.PushBackSpeed)
    pushBackTimer = this.PushBackDuration

    collisionStopTimer = this.CollisionStopTime

    if iceRigidbody ~= nil then
        local velocity = tryGet(iceRigidbody, "velocity")
        if velocity ~= nil then
            local inwardSpeed = velocity.x * direction.x + velocity.z * direction.z
            if inwardSpeed < 0 then
                velocity.x = velocity.x - direction.x * inwardSpeed
                velocity.z = velocity.z - direction.z * inwardSpeed
                iceRigidbody.velocity = velocity
            end
        end
    end

    if iceRigidbody ~= nil and this.PushBackForce > 0 then
        local force = Vector3(direction.x * this.PushBackForce, 0, direction.z * this.PushBackForce)
        local ok = false

        if VFramework ~= nil and VFramework.ForceMode ~= nil and VFramework.ForceMode.VelocityChange ~= nil then
            ok = pcall(function()
                iceRigidbody:AddForce(force, VFramework.ForceMode.VelocityChange)
            end)
        end

        if not ok then
            pcall(function()
                iceRigidbody:AddForce(force)
            end)
        end
    end

    keepIceGrounded()
end

local function finishIfNeeded(vObject)
    if isFinished or vObject == nil then
        return false
    end

    if not isNamedOrChildOf(vObject, this.FinishName) then
        return false
    end

    isFinished = true
    isPaused = true
    callEvent(getScriptEvent("OnFinishReached"))
    if scriptObject ~= nil then
        scriptObject:Log("Ice_Cube reached the finish.")
    end
    return true
end

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
    pushBackVelocity = Vector3(0, 0, 0)

    if serviceApi ~= nil then
        playerService = serviceApi.playerService
        physicsService = serviceApi.physicsService
    end
end

function this.OnStart()
    local iceCube = resolveIceCube()
    if iceCube == nil or iceCube.transform == nil then
        if scriptObject ~= nil then
            scriptObject:Log("IceCubePlatformController could not find Ice_Cube.")
        end
        return
    end

    iceTransform = iceCube.transform
    iceRigidbody = getComponent(iceCube, "Rigidbody")
    startScale = iceTransform.localScale
    currentHeight = startScale.y
    bottomY = iceTransform.position.y - currentHeight * 0.5

    if playerService ~= nil then
        playerService.OnCreateCharacter:AddListener(setTargetFromPlayer)
        playerService.OnDestroyCharacter:AddListener(clearTargetFromPlayer)
        acquireTargetCharacter()
    end

    if resolveIceBallObjects() then
        scheduleNextIceBall()
    end
end

local function updatePlatform(deltaTime)
    if isFinished or isPaused then return end
    if iceTransform == nil then return end

    if impactFeedbackCooldown > 0 then
        impactFeedbackCooldown = math.max(0, impactFeedbackCooldown - deltaTime)
    end

    detectDropPlatformBelow()
    updateDropPlatforms(deltaTime)
    updateIceBallRain(deltaTime)
    keepPlayersOnIceTop()

    if collisionStopTimer > 0 then
        collisionStopTimer = collisionStopTimer - deltaTime
    end

    if damageCooldownTimer > 0 then
        damageCooldownTimer = damageCooldownTimer - deltaTime
    end

    if pushBackTimer > 0 then
        pushBackTimer = pushBackTimer - deltaTime
    else
        pushBackVelocity = Vector3(0, 0, 0)
    end

    local icePos = iceTransform.position
    local moveX = 0
    local moveZ = 0
    local contributors = 0

    if this.EnableMultiplayerControl == true then
        local multiplayerMoveX, multiplayerMoveZ, multiplayerContributors =
            calculateMultiplayerMove(icePos)

        if multiplayerMoveX ~= nil and multiplayerMoveZ ~= nil then
            moveX = multiplayerMoveX
            moveZ = multiplayerMoveZ
            contributors = multiplayerContributors
        end
    end

    if contributors <= 0 and not acquireTargetCharacter() then
        targetLogTime = targetLogTime + deltaTime
        if targetLogTime >= 3 then
            targetLogTime = 0
            if scriptObject ~= nil then
                scriptObject:Log("IceCubePlatformController is waiting for player characters.")
            end
        end
        return
    end

    if contributors <= 0 then
        local targetTransform = tryGet(this.TargetCharacter, "transform")
        if targetTransform == nil then return end

        local charPos = targetTransform.position
        local offsetX = charPos.x - icePos.x
        local offsetZ = charPos.z - icePos.z

        if math.abs(offsetX) > this.ControlDeadZone then
            moveX = offsetX * this.ControlStrength
        end

        if math.abs(offsetZ) > this.ControlDeadZone then
            moveZ = offsetZ * this.ControlStrength
        end
    end

    local speed = math.sqrt(moveX * moveX + moveZ * moveZ)
    if speed > this.MaxMoveSpeed and speed > 0 then
        local ratio = this.MaxMoveSpeed / speed
        moveX = moveX * ratio
        moveZ = moveZ * ratio
    end

    if collisionStopTimer > 0 then
        moveX = 0
        moveZ = 0
    end

    local inputBlend = clamp((this.MoveInputSmoothing or 7.0) * deltaTime, 0, 1)
    smoothedMoveX = smoothedMoveX + (moveX - smoothedMoveX) * inputBlend
    smoothedMoveZ = smoothedMoveZ + (moveZ - smoothedMoveZ) * inputBlend

    local finalMoveX = smoothedMoveX + pushBackVelocity.x
    local finalMoveZ = smoothedMoveZ + pushBackVelocity.z

    currentHeight = currentHeight - this.MeltRate * deltaTime
    currentHeight = clamp(currentHeight, 0, startScale.y)

    local scale = iceTransform.localScale
    scale.x = startScale.x
    scale.y = currentHeight
    scale.z = startScale.z
    syncTransformScale(iceTransform, scale)

    keepIceGrounded(icePos)
    moveIce(finalMoveX, finalMoveZ, deltaTime)

    if currentHeight <= this.MinHeight then
        applyHeight()
    end
end

function this.OnFixedUpdate(deltaTime)
    updatePlatform(deltaTime)
end

function this.OnCollisionEnter(collision)
    if collision ~= nil then
        tryAssignCharacterFromVObject(collision.vObject)
        startDropPlatform(collision.vObject)
        if finishIfNeeded(collision.vObject) then return end
    end

    if not shouldDamageFromCollision(collision) then return end

    pushBackFromObstacleCollision(collision)

    if damageCooldownTimer > 0 then return end

    local speed = getVectorMagnitude(collision.relativeVelocity)
    local damage = this.ImpactDamage + speed * this.ImpactSpeedDamageScale
    damageIce(damage)
    damageCooldownTimer = this.DamageCooldown
end

function this.OnCollisionStay(collision)
    if collision ~= nil then
        startDropPlatform(collision.vObject)
        if finishIfNeeded(collision.vObject) then return end
    end

    if not shouldDamageFromCollision(collision) then return end

    pushBackFromObstacleCollision(collision)

    if damageCooldownTimer > 0 then return end

    damageIce(this.ImpactDamage)
    damageCooldownTimer = this.DamageCooldown
end

function this.OnTriggerEnter(collider)
    if collider == nil then return end

    local hitObject = collider.vObject
    startDropPlatform(hitObject)
    finishIfNeeded(hitObject)
end

function this.OnTriggerStay(collider)
    if collider == nil then return end
    startDropPlatform(collider.vObject)
    finishIfNeeded(collider.vObject)
end

function this.OnDestroy()
    if playerService ~= nil then
        playerService.OnCreateCharacter:RemoveListener(setTargetFromPlayer)
        playerService.OnDestroyCharacter:RemoveListener(clearTargetFromPlayer)
    end
end

__EX_FUNCTION__(this, __EX_VARIABLE__.vobject())
function this.SetTarget(target)
    this.TargetCharacter = target
end

__EX_FUNCTION__(this, __EX_VARIABLE__.float())
function this.DamageIce(amount)
    damageIce(amount)
end

__EX_FUNCTION__(this, __EX_VARIABLE__.bool())
function this.SetPaused(paused)
    isPaused = paused
end

__EX_FUNCTION__(this)
function this.ResetIce()
    if iceTransform == nil or startScale == nil then return end

    isFinished = false
    isPaused = false
    collisionStopTimer = 0
    damageCooldownTimer = 0
    pushBackTimer = 0
    pushBackVelocity = Vector3(0, 0, 0)
    smoothedMoveX = 0
    smoothedMoveZ = 0
    fallbackVelocityX = 0
    fallbackVelocityZ = 0
    currentHeight = startScale.y
    scheduleNextIceBall()
    applyHeight()
end
