local this = __CREATOR__.new()

local serviceApi
local script
local animator
local knockbackScript

this.KnockbackServer = __EX_VARIABLE__.vobject()
this.PlayAnimationNames = __EX_VARIABLE__.list(__EX_VARIABLE__.string())
this.AutoStart = __EX_VARIABLE__.bool(true)
this.StartEvent = __EX_VARIABLE__.event()

local playStateHashMap = {}
local currentPlayStateHash = nil
local lastStartEventLoopIndex = -1
local isStartEventCalled = false
local startTime = 0
local endTime = 1

local function getFirstStateName()
    if this.PlayAnimationNames == nil then return nil end
    if #this.PlayAnimationNames <= 0 then return nil end
    return this.PlayAnimationNames[1]
end

local function resetStartEventState()
    lastStartEventLoopIndex = -1
    isStartEventCalled = false
end

function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject    
    
    animator = script.parent:GetComponentInChildren("Animator")
    if animator == nil then
        script:Log("[PunchBumperServer] animator is nil")
    end

    if this.PlayAnimationNames ~= nil then
        for i = 1, #this.PlayAnimationNames do
            local name = this.PlayAnimationNames[i]
            if name ~= nil and name ~= "" then
                playStateHashMap[name] = VFramework.Animator.StringToHash(name)
            end
        end
    end

    if this.KnockbackServer == nil then
        script:Log("[PunchBumperServer] KnockbackServer is nil")
    else
        knockbackScript = this.KnockbackServer:GetLua()
        if knockbackScript == nil then
            script:Log("[PunchBumperServer] knockback script is nil")
        else
            knockbackScript:ChangeDisableInternalMode()
        end
    end

    if animator ~= nil then
        if this.AutoStart then
            animator.enabled = true
            local firstName = getFirstStateName()
            if firstName ~= nil then
                this.Play(firstName)
            end
        else
            animator.enabled = false
        end
    end

end

function this.Play(stateName)
    if animator == nil then return end
    if stateName == nil or stateName == "" then return end

    local stateHash = playStateHashMap[stateName]
    if stateHash == nil then return end

    currentPlayStateHash = stateHash
    resetStartEventState()
    animator:Play(stateHash, 0, 0)
end

function this.OnUpdate(deltaTime)
    if animator == nil then return end
    if animator.enabled == false then return end
    if currentPlayStateHash == nil then return end
    if this.StartEvent == nil then return end

    local stateInfo = animator:GetCurrentAnimatorStateInfo(0)
    if stateInfo == nil then return end
    if stateInfo.shortNameHash ~= currentPlayStateHash and stateInfo.fullPathHash ~= currentPlayStateHash then return end

    local normalizedTime = stateInfo.normalizedTime
    if normalizedTime < 0 then return end

    local loopIndex = math.floor(normalizedTime)
    if loopIndex ~= lastStartEventLoopIndex then
        lastStartEventLoopIndex = loopIndex
        isStartEventCalled = false
    end

    if isStartEventCalled then return end

    local loopTime = normalizedTime - loopIndex

    if startTime == endTime then
        if loopTime >= startTime then
            isStartEventCalled = true
            this.StartEvent:Call()
            --script:Log("[Punch] start called")
        end
        return
    end

    if loopTime >= startTime and loopTime <= endTime then
        isStartEventCalled = true
        this.StartEvent:Call()
        --script:Log("[Punch] start called")
    end
end

__EX_FUNCTION__(this)
function this.OnStartEvent()
    if this.AutoStart then return end
    if animator == nil then return end

    animator.enabled = true
    local firstName = getFirstStateName()
    if firstName == nil then return end

    this.Play(firstName)
end

__EX_FUNCTION__(this, _VOBJECT_.vobject())
function this.OnListenCollisionEnter(collideCharacter)
    if collideCharacter == nil then return end
    if knockbackScript == nil then return end

    knockbackScript.KnockbackAround(collideCharacter)
end
