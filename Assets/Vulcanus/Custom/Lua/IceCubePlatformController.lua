local this = __CREATOR__.new()

this.IceCube = __EX_VARIABLE__.vobject()
this.TargetCharacter = __EX_VARIABLE__.vobject()
this.UseLocalPlayer = __EX_VARIABLE__.bool(true)

this.ControlDeadZone = __EX_VARIABLE__.float(0.25)
this.ControlStrength = __EX_VARIABLE__.float(1.4)
this.MaxMoveSpeed = __EX_VARIABLE__.float(7.0)
this.MoveAcceleration = __EX_VARIABLE__.float(18.0)

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

this.ObstacleNamePrefix = __EX_VARIABLE__.string("Obstacle")
this.FinishName = __EX_VARIABLE__.string("Finish_Line")

this.OnIceMelted = __EX_VARIABLE__.event()
this.OnFinishReached = __EX_VARIABLE__.event()
this.OnIceDamaged = __EX_VARIABLE__.event("float damage", "float height")

local serviceApi
local scriptObject
local playerService
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
local pushBackVelocity = Vector3(0, 0, 0)

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

local function isObstacleVObject(vObject)
    local current = vObject

    for _ = 1, 8 do
        if current == nil then
            return false
        end

        if startsWith(getVObjectName(current), this.ObstacleNamePrefix) then
            return true
        end

        current = tryGet(current, "parent")
    end

    return false
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

    if this.UseLocalPlayer then
        if player.isLocalPlayer then
            this.TargetCharacter = player.character
        end
    elseif this.TargetCharacter == nil then
        this.TargetCharacter = player.character
    end
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

local function damageIce(amount)
    if isFinished or isPaused then return end
    if amount == nil or amount <= 0 then return end

    currentHeight = currentHeight - amount
    applyHeight()
    callEvent(getScriptEvent("OnIceDamaged"), amount, currentHeight)
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

local function moveIce(moveX, moveZ, deltaTime)
    if iceRigidbody ~= nil and this.UseRigidbodyMove == true then
        local velocity = tryGet(iceRigidbody, "velocity")
        if velocity == nil then
            velocity = Vector3(0, 0, 0)
        end

        local acceleration = this.MoveAcceleration or 18.0
        local force = Vector3(
            (moveX - velocity.x) * acceleration,
            0,
            (moveZ - velocity.z) * acceleration
        )
        local usedAcceleration = false

        if VFramework ~= nil and VFramework.ForceMode ~= nil and VFramework.ForceMode.Acceleration ~= nil then
            usedAcceleration = pcall(function()
                iceRigidbody:AddForce(force, VFramework.ForceMode.Acceleration)
            end)
        end

        if not usedAcceleration then
            iceRigidbody:AddForce(force)
        end

        return
    end

    local position = iceTransform.position
    position.x = position.x + moveX * deltaTime
    position.z = position.z + moveZ * deltaTime
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

    local name = getVObjectName(vObject)
    if name ~= this.FinishName then
        return false
    end

    isFinished = true
    callEvent(getScriptEvent("OnFinishReached"))
    if scriptObject ~= nil then
        scriptObject:Log("Ice_Cube reached the finish.")
    end
    return true
end

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject

    if serviceApi ~= nil then
        playerService = serviceApi.playerService
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
end

local function updatePlatform(deltaTime)
    if isFinished or isPaused then return end
    if iceTransform == nil then return end

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

    if not acquireTargetCharacter() then
        targetLogTime = targetLogTime + deltaTime
        if targetLogTime >= 3 then
            targetLogTime = 0
            if scriptObject ~= nil then
                scriptObject:Log("IceCubePlatformController is waiting for a target character.")
            end
        end
        return
    end

    local icePos = iceTransform.position
    local targetTransform = tryGet(this.TargetCharacter, "transform")
    if targetTransform == nil then return end

    local charPos = targetTransform.position
    local offsetX = charPos.x - icePos.x
    local offsetZ = charPos.z - icePos.z

    local moveX = 0
    local moveZ = 0

    if math.abs(offsetX) > this.ControlDeadZone then
        moveX = offsetX * this.ControlStrength
    end

    if math.abs(offsetZ) > this.ControlDeadZone then
        moveZ = offsetZ * this.ControlStrength
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

    local finalMoveX = moveX + pushBackVelocity.x
    local finalMoveZ = moveZ + pushBackVelocity.z

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
    if not shouldDamageFromCollision(collision) then return end

    pushBackFromObstacleCollision(collision)

    if damageCooldownTimer > 0 then return end

    damageIce(this.ImpactDamage)
    damageCooldownTimer = this.DamageCooldown
end

function this.OnTriggerEnter(collider)
    if collider == nil then return end

    local hitObject = collider.vObject
    finishIfNeeded(hitObject)
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
    currentHeight = startScale.y
    applyHeight()
end
