local this = __CREATOR__.new()

this.TargetTimeSeconds = __EX_VARIABLE__.float(10.0)

this.OnTimerStart = __EX_VARIABLE__.event(__EX_VARIABLE__.float(), __EX_VARIABLE__.float())
this.OnTimerFinish = __EX_VARIABLE__.event()

this.OnResetTimer = __EX_VARIABLE__.event()

this.IsRunning = __EX_VARIABLE__.bool(false)

local serviceApi
local scriptObject

function this.OnStart()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
end

local asyncHandle = nil

local function checkTimeDuration()

    this.IsRunning = true

    local startServerTime = serviceApi.room.elapsedTime
    this.OnTimerStart:Call(startServerTime, this.TargetTimeSeconds)

    print('Timer Server : ', startServerTime)

    VFramework.WaitForSeconds(this.TargetTimeSeconds)

    local finishServerTime = serviceApi.room.elapsedTime
    print('Timer Server : ',finishServerTime, finishServerTime - startServerTime)

    asyncHandle = nil
    this.IsRunning = false
    this.OnTimerFinish:Call()
end

__EX_FUNCTION__(this)
function this.StartTime()   
    
    asyncHandle = scriptObject:AsyncCall(checkTimeDuration)
end


__EX_FUNCTION__(this)
function this.ResetTime()
    if asyncHandle then
        asyncHandle:Stop()
        asyncHandle = nil
        this.IsRunning = false

        this.OnResetTimer:Call()
    end
end
