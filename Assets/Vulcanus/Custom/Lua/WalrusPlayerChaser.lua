local this = __CREATOR__.new()

this.Walrus = __EX_VARIABLE__.vobject()
this.MoveSpeed = __EX_VARIABLE__.float(5.0)
this.TurnSpeed = __EX_VARIABLE__.float(180.0)
this.StopDistance = __EX_VARIABLE__.float(10.0)
this.TargetRefreshInterval = __EX_VARIABLE__.float(0.25)

local serviceApi
local scriptObject
local playerService
local walrus
local walrusTransform
local targetCharacter
local targetRefreshTimer = 0
local fixedY = 0

local function tryGet(target, key)
    if target == nil then return nil end

    local ok, value = pcall(function()
        return target[key]
    end)

    if ok then return value end
    return nil
end

local function isUsableCharacter(character)
    if character == nil or character.transform == nil then return false end
    if tryGet(character, "isFalling") == true then return false end
    return true
end

local function findNearestCharacter()
    if playerService == nil or walrusTransform == nil then
        return nil
    end

    local ok, players = pcall(function()
        return playerService:GetPlayers()
    end)
    if not ok or players == nil then return nil end

    local walrusPosition = walrusTransform.position
    local nearest = nil
    local nearestDistanceSquared = math.huge

    for _, player in ipairs(players) do
        local character = player ~= nil and player.character or nil

        if isUsableCharacter(character) then
            local position = character.transform.position
            local dx = position.x - walrusPosition.x
            local dz = position.z - walrusPosition.z
            local distanceSquared = dx * dx + dz * dz

            if distanceSquared < nearestDistanceSquared then
                nearest = character
                nearestDistanceSquared = distanceSquared
            end
        end
    end

    return nearest
end

local function updateTarget(deltaTime)
    targetRefreshTimer = targetRefreshTimer - deltaTime
    if targetRefreshTimer > 0 and isUsableCharacter(targetCharacter) then
        return
    end

    targetRefreshTimer = math.max(this.TargetRefreshInterval, 0.05)
    targetCharacter = findNearestCharacter()
end

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject

    if serviceApi ~= nil then
        playerService = serviceApi.playerService
    end
end

function this.OnStart()
    if scriptObject == nil then return end

    walrus = this.Walrus
    if walrus == nil or walrus.transform == nil then
        scriptObject:Log("WalrusPlayerChaser has no Walrus target.")
        return
    end

    walrusTransform = walrus.transform
    fixedY = walrusTransform.position.y
    targetCharacter = findNearestCharacter()
    scriptObject:Log("WalrusPlayerChaser started.")
end

function this.OnUpdate(deltaTime)
    if walrusTransform == nil then return end

    updateTarget(deltaTime)
    if not isUsableCharacter(targetCharacter) then
        return
    end

    local currentPosition = walrusTransform.position
    local targetPosition = targetCharacter.transform.position
    local dx = targetPosition.x - currentPosition.x
    local dz = targetPosition.z - currentPosition.z
    local distance = math.sqrt(dx * dx + dz * dz)

    if distance <= this.StopDistance or distance <= 0.001 then
        return
    end

    local direction = Vector3.New(dx / distance, 0, dz / distance)
    local desiredRotation = Quaternion.LookRotation(direction, Vector3.up)
    local nextRotation = Quaternion.RotateTowards(
        walrusTransform.rotation,
        desiredRotation,
        this.TurnSpeed * deltaTime
    )

    local moveDistance = math.min(this.MoveSpeed * deltaTime, distance - this.StopDistance)
    local nextPosition = Vector3.New(
        currentPosition.x + direction.x * moveDistance,
        fixedY,
        currentPosition.z + direction.z * moveDistance
    )

    walrusTransform.rotation = nextRotation
    walrusTransform.position = nextPosition
    walrusTransform:SyncTransform()
end
