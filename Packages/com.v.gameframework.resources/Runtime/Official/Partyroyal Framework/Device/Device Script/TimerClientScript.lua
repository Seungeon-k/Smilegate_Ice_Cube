local this = __CREATOR__.new()

this.OnTimerStart = __EX_VARIABLE__.event()
this.OnTimerComplete = __EX_VARIABLE__.event()
this.OnScheduledEachSeconds = __EX_VARIABLE__.event(__EX_VARIABLE__.int())
this.OnScheduledEachMilliseconds = __EX_VARIABLE__.event(__EX_VARIABLE__.int())

local serviceApi
local scriptObject

local timeSlotMilliseconds = 100

function this.OnStart()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
end

local asyncHandle = nil

-- 서버 기준
local startServerTime = 0
local endServerTime = 0
local slotTimeMS = timeSlotMilliseconds

local lastNow = -1
local function asyncAction()
    -- UI용 tick: 마지막으로 보낸 슬롯(ms)
    local lastTickMS = -1

    while true do
        local now = serviceApi.room.elapsedTime
        local remain = endServerTime - now
        if remain <= 0 then break end

        -- 진행도(ms): 누적 대신 매번 서버시간으로 계산
        local elapsedMS = (now - startServerTime) * 1000
        if elapsedMS < 0 then elapsedMS = 0 end -- 동기화 튐 방어

        -- 대충 100ms마다 한 번만 호출(밀린 거 catch-up 안 함)
        local tickMS = math.floor(elapsedMS / slotTimeMS) * slotTimeMS
        if tickMS ~= lastTickMS and tickMS > 0 then
            lastTickMS = tickMS
            -- 필요하면 여기서 UI 업데이트 이벤트
            this.OnScheduledEachMilliseconds:Call(tickMS)

            -- 초 단위도 대충
            if tickMS % 1000 == 0 then
                this.OnScheduledEachSeconds:Call(tickMS / 1000)
            end
        end

        -- 다음 슬롯까지 남은 시간만큼, 혹은 최대 100ms만 sleep
        local toNextSlotMS = (tickMS + slotTimeMS) - elapsedMS
        if toNextSlotMS < 1 then toNextSlotMS = 1 end

        local waitSec = math.min(remain, toNextSlotMS * 0.001)
        if now == lastNow then
            waitSec = math.min(remain, slotTimeMS * 0.001) -- fallback
        end
        lastNow = now

        if waitSec < 0.01 then waitSec = 0.01 end -- 최소 10ms
        VFramework.WaitForSeconds(waitSec)
    end

    this.OnTimerComplete:Call()
    asyncHandle = nil
end

__EX_FUNCTION__(this, __EX_VARIABLE__.float(), __EX_VARIABLE__.float())
function this.StartTime(serverTime, targetTime)
    slotTimeMS = timeSlotMilliseconds

    startServerTime = serverTime
    endServerTime = serverTime + targetTime

    if asyncHandle then
        asyncHandle:Stop()
        asyncHandle = nil
    end

    this.OnTimerStart:Call()

    asyncHandle = scriptObject:AsyncCall(asyncAction)
end

__EX_FUNCTION__(this)
function this.FinishTime()
    if asyncHandle then
        asyncHandle:Stop()
        asyncHandle = nil
    end

    -- 서버에서 finish가 왔으면 UI도 즉시 종료 처리
    this.OnTimerComplete:Call()
end

__EX_FUNCTION__(this)
function this.ResetTime()
    if asyncHandle then
        asyncHandle:Stop()
        asyncHandle = nil
    end
end
