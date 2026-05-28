local this = __CREATOR__.new()

this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
this.FallDistance = __EX_VARIABLE__.float(3)
this.FallSpeed = __EX_VARIABLE__.float(1)

this.CanRespawn = __EX_VARIABLE__.bool(true)
this.RespawnDelay = __EX_VARIABLE__.float(5)

this.EnableCollisionResponse = __EX_VARIABLE__.bool(true)

this.nowFalling = __EX_VARIABLE__.bool()
this.platformObject = __EX_VARIABLE__.vobject()
this.platformCollider = _VCOMPONENT_.collider()
this.platformRigidbody = _VCOMPONENT_.rigidbody()

this.visibleScript = _VOBJECT_.script():lua()

local serviceApi
local scriptObject
local soundService

local enteredSomeone = false
local enteredObjects = {}

local originPosition

local function countMap(t)
    local n = 0
    for k, v in pairs(t) do
        if v then
            n = n + 1
        end
    end
    return n
end

local moveDirection = 0
local accumulatedMoveDistance

local function moveToDown()
    moveDirection = -1
end

local function moveToUp()
    moveDirection = 1
end

local function stopMove()
    moveDirection = 0
end

local function canMove()
    return this.EnableCollisionResponse and moveDirection ~= 0
end

local function getMoveSpeed()
    return (moveDirection == 1) and 1 or this.FallSpeed
end

local function applyCollision()
    if enteredSomeone then
        moveToDown()
    else
        stopMove()
    end
end

local function showPlatform()
    if not this.visibleScript.CurrentVisible then
        this.visibleScript.Show()    
    end
end

local function hidePlatform()
    if this.visibleScript.CurrentVisible then
        this.visibleScript.Hide()
    end
end

local function resetMove()
    accumulatedMoveDistance = this.FallDistance

    this.platformRigidbody.isKinematic = true
    this.platformRigidbody.useGravity = false

    this.platformCollider.enabled = true
    this.nowFalling = false

    this.platformObject.transform.position = originPosition
end

local function disappear()
    VFramework.WaitForSeconds(1.5)
    hidePlatform()
    VFramework.WaitForSeconds(0.5)
    resetMove()

    if this.CanRespawn then
        VFramework.WaitForSeconds(this.RespawnDelay)
        showPlatform()
    end
end

local function doFalling()
    this.platformRigidbody.isKinematic = false
    this.platformRigidbody.useGravity = true

    this.platformCollider.enabled = false
    this.nowFalling = true

    scriptObject:AsyncCall(disappear)
end


function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
    soundService = serviceApi.soundService

    this.visibleScript.IsVisibleOnStart = this.IsVisibleOnStart
end

function this.OnStart()    
    accumulatedMoveDistance = this.FallDistance

    originPosition = this.platformObject.transform.position
end

function this.OnFixedUpdate(fixedDeltaTime)
    if canMove() then
        local moveSpeed = getMoveSpeed()

        local moveDistance = moveSpeed * moveDirection * fixedDeltaTime

        local currentTotalMoveDistance = accumulatedMoveDistance + moveDistance

        if currentTotalMoveDistance < 0 then

            stopMove()

            doFalling()
            
        else
            local moveFactor = Vector3.up * moveDistance
            this.platformRigidbody:MovePosition(this.platformRigidbody.position + moveFactor)

            accumulatedMoveDistance = currentTotalMoveDistance
        end
    end
end

function this.OnCollisionEnter(collision)
    
    if enteredObjects[collision.vObject] then
        return
    end

    local ok, _ = collision.vObject:CastByType(typeof(VFramework.Character))
    if not ok then
        return
    end

    enteredObjects[collision.vObject] = true

    local enteredCount = countMap(enteredObjects)

    enteredSomeone = enteredCount > 0

    applyCollision()
    print('FallingPlatform CollisionEnter : ', enteredCount)

end

function this.OnCollisionExit(collision)
    
    if enteredObjects[collision.vObject] then

        enteredObjects[collision.vObject] = false

        local enteredCount = countMap(enteredObjects)

        enteredSomeone = enteredCount > 0
    
        applyCollision()
        print('FallingPlatform CollisionExit : ', enteredCount)

    end    
end

__EX_FUNCTION__(this)
function this.Show()
    showPlatform()   
end

__EX_FUNCTION__(this)
function this.Hide()
    hidePlatform()
end

__EX_FUNCTION__(this)
function this.ResetState()
    resetMove()
end

__EX_FUNCTION__(this)
function this.EnableDescendReaction()
    this.EnableCollisionResponse = true
end

__EX_FUNCTION__(this)
function this.DisableDescendResponse()
    this.EnableCollisionResponse = false
end
