local this = __CREATOR__.new()

-- number control options
this.DisplayNumberOnStart = __EX_VARIABLE__.bool(true)
this.CurrentNumber = __EX_VARIABLE__.int(1)
this.UseRandomNumberFirst = __EX_VARIABLE__.bool(true)

this.RandomNumberMin = __EX_VARIABLE__.int(0)
this.RandomNumberMax = __EX_VARIABLE__.int(5)

-- move control options
this.EnableCollisionResponse = __EX_VARIABLE__.bool(true)
this.VerticalTravelDistance = __EX_VARIABLE__.float(5)
this.DescendSpeed = __EX_VARIABLE__.float(1)
this.CanGoBackGeneralNumber = __EX_VARIABLE__.bool(true)
this.CanGoBackZeroNumber = __EX_VARIABLE__.bool(false)
this.ReturnDelay = __EX_VARIABLE__.float(1)
this.ReturnSpeed = __EX_VARIABLE__.float(1)


this.lifterRigidbody = _VCOMPONENT_.rigidbody()
this.lifterRenderer = _VCOMPONENT_.renderer()
this.overloadMaterial = _VASSET_.material()

this.soundOverLight = _VASSET_.audioClip()
this.soundOverLightLoop = _VASSET_.audioClip()

this.numbers = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())

local serviceApi
local scriptObject
local soundService

local enteredOver = false
local enteredObjects = {}

local originMaterial;


local function countMap(t)
    local n = 0
    for k, v in pairs(t) do
        if v then
            n = n + 1
        end
    end
    return n
end

local function makeDisplayNumber()
    if this.UseRandomNumberFirst then
        this.CurrentNumber = math.random(this.RandomNumberMin, this.RandomNumberMax)
    end
end

local function displayNumberObject(displayNumber)
    local displayNumberObject = this.numbers[displayNumber + 1]
    displayNumberObject:SetActive(true)
end

local function clearNumber()    
    for _, v in ipairs(this.numbers) do
        v:SetActive(false)
    end
end

local moveDirection = 0
local accumulatedMoveDistance
local goBackDelay = 0.0

local mustMoveToResetPosition = false
local speedForResetPosition = 3

local function moveToDown()
    moveDirection = -1
end

local function moveToUp(delay)
    moveDirection = 1
    goBackDelay = delay
end

local function changeOverloadColor()
    this.lifterRenderer.sharedMaterial = this.overloadMaterial
end

local function changeOriginColor()
    this.lifterRenderer.sharedMaterial = originMaterial
end

local loopSoundId = 0
local function playLoopSound()
    if loopSoundId <= 0 then
        local soundPlayPosition = scriptObject.parent.transform.position
        loopSoundId = soundService:PlayAtPosition(this.soundOverLightLoop, soundPlayPosition, 1, 1, 25, 1, true)
    end
end

local function stopLoopSound()
    if loopSoundId > 0 then
        soundService:Stop(loopSoundId)
        loopSoundId = 0
    end
end

local function applyCollision()

    local enteredCount = countMap(enteredObjects)
    enteredOver = enteredCount > this.CurrentNumber

    print('OverloadDownLift CollisionEnter : ', scriptObject, this.CurrentNumber, enteredCount)

    if enteredOver then
        moveToDown()
        changeOverloadColor()
        
        soundService:Play(this.soundOverLight)

        playLoopSound()        
    else
        moveToUp(this.ReturnDelay)
        changeOriginColor()
        stopLoopSound()
    end
end

local function stopMove()
    moveDirection = 0

    if mustMoveToResetPosition then
        mustMoveToResetPosition = false
        applyCollision()
    end
end

local function canMove()
    return this.EnableCollisionResponse and moveDirection ~= 0
end

local function canGoBackNumber()
    return (this.CurrentNumber > 0) and this.CanGoBackGeneralNumber or this.CanGoBackZeroNumber
end

local function canGoBack(deltaTime)
    if not mustMoveToResetPosition and moveDirection == 1 then
        if canGoBackNumber() then
            if goBackDelay > 0 then
                goBackDelay = goBackDelay - deltaTime

                if goBackDelay < 0 then
                    goBackDelay = 0
                else
                    return false
                end
            end
        else
            return false
        end
    end

    return true
end

local function getMoveSpeed()
    if mustMoveToResetPosition then return speedForResetPosition end

    return (moveDirection == 1) and this.ReturnSpeed or this.DescendSpeed
end


function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
    soundService = serviceApi.soundService
    originMaterial = this.lifterRenderer.sharedMaterial;

    

    clearNumber()

    accumulatedMoveDistance = this.VerticalTravelDistance
end

function this.OnStart()
    if this.DisplayNumberOnStart then        
        makeDisplayNumber()
        displayNumberObject(this.CurrentNumber)
    end
end



function this.OnFixedUpdate(fixedDeltaTime)
    if canMove() and canGoBack(fixedDeltaTime) then
        local moveSpeed = getMoveSpeed()

        local moveDistance = moveSpeed * moveDirection * fixedDeltaTime

        local currentTotalMoveDistance = accumulatedMoveDistance + moveDistance

        if currentTotalMoveDistance < 0 or currentTotalMoveDistance >= this.VerticalTravelDistance then            

            local lastOneStepMoveDistance

            if currentTotalMoveDistance < 0 then
                lastOneStepMoveDistance = accumulatedMoveDistance
                accumulatedMoveDistance = 0
            end

            if currentTotalMoveDistance >= this.VerticalTravelDistance then
                lastOneStepMoveDistance = this.VerticalTravelDistance - accumulatedMoveDistance
                accumulatedMoveDistance = this.VerticalTravelDistance
            end

            local moveFactor = Vector3.up * lastOneStepMoveDistance
            this.lifterRigidbody:MovePosition(this.lifterRigidbody.position + moveFactor)

            stopMove()
            stopLoopSound()
            
        else
            local moveFactor = Vector3.up * moveDistance
            this.lifterRigidbody:MovePosition(this.lifterRigidbody.position + moveFactor)

            accumulatedMoveDistance = currentTotalMoveDistance
        end
        
    end
end


function this.OnCollisionEnter(collision)

    local ok, character = collision.vObject:CastByType(typeof(VFramework.Character))
    if not ok then
        return
    end

    if enteredObjects[character.player.id] then
        return
    end

    enteredObjects[character.player.id] = true

    if this.EnableCollisionResponse then
        applyCollision()        
    end
end

function this.OnCollisionExit(collision)
    
    local ok, character = collision.vObject:CastByType(typeof(VFramework.Character))
    if not ok then
        return
    end
    
    if enteredObjects[character.player.id] then

        enteredObjects[character.player.id] = false
    
        if this.EnableCollisionResponse then            
            applyCollision()            
        end
    end    
end

__EX_FUNCTION__(this)
function this.DisplayConfiguredNumber()
    makeDisplayNumber()
    clearNumber()
    displayNumberObject(this.CurrentNumber)
end

__EX_FUNCTION__(this, __EX_VARIABLE__.int())
function this.DisplayNumber(displayNumber)    
    this.CurrentNumber = displayNumber
    clearNumber()
    displayNumberObject(displayNumber)
end

__EX_FUNCTION__(this)
function this.ClearNumber()
    clearNumber()
end

__EX_FUNCTION__(this)
function this.ResetPosition()
    moveToUp(0)
    mustMoveToResetPosition = true
    enteredOver = false
    enteredObjects = {}

    stopLoopSound()
end

__EX_FUNCTION__(this)
function this.EnableDescendReaction()
    this.EnableCollisionResponse = true
    applyCollision()
end

__EX_FUNCTION__(this)
function this.DisableDescendResponse()
    this.EnableCollisionResponse = false
    changeOriginColor()
    stopLoopSound()
end
