local this = __CREATOR__.new() -- 스크립트 인스턴스

local serviceApi -- 서비스 API 캐시
local script -- 스크립트 오브젝트 캐시
local targetTransform -- 대상 트랜스폼 캐시
local rigidBody = nil

this.AutoStart = __EX_VARIABLE__.bool(true) -- 시작 시 자동 재생
this.Duration = __EX_VARIABLE__.float(1.0) -- 재생 시간
this.Loop = __EX_VARIABLE__.bool(false) -- 루프 여부
this.PingPong = __EX_VARIABLE__.bool(false) -- 왕복 여부
this.CycleDelay = __EX_VARIABLE__.float(0.0) -- 사이클 간 지연

--this.FromValue = __EX_VARIABLE__.vector3() -- 시작 오프셋
--this.ToValue = __EX_VARIABLE__.vector3() -- 종료 오프셋
this.PositionDelta = __EX_VARIABLE__.vector3()
this.UseOnlyCalculator = __EX_VARIABLE__.bool(false) -- 왕복 여부
this.OnTweenEvent = __EX_VARIABLE__.event(__EX_VARIABLE__.vector3())

-- this.EaseInSine = __EX_VARIABLE__.bool(false) -- 사인 In 이징
-- this.EaseOutSine = __EX_VARIABLE__.bool(false) -- 사인 Out 이징
this.EaseInOutSine = __EX_VARIABLE__.bool(false) -- 사인 InOut 이징
-- this.EaseInCubic = __EX_VARIABLE__.bool(false) -- 큐빅 In 이징
-- this.EaseOutCubic = __EX_VARIABLE__.bool(false) -- 큐빅 Out 이징
-- this.EaseInOutCubic = __EX_VARIABLE__.bool(false) -- 큐빅 InOut 이징
local easeInSine = false -- 사인 In 이징
local easeOutSine = false -- 사인 Out 이징a
--local easeInOutSine = false -- 사인 InOut 이징
local easeInCubic = false -- 큐빅 In 이징
local easeOutCubic = false -- 큐빅 Out 이징
local easeInOutCubic = false -- 큐빅 InOut 이징

--this.OnStartEvent = __EX_VARIABLE__.event() -- 시작 이벤트
this.OnFinishEvent = __EX_VARIABLE__.event() -- 완료 이벤트

local elapsed = 0 -- 경과 시간 누적
local delayTimer = 0 -- 지연 카운트다운
local isPlaying = false -- 재생 상태 플래그
local isReversed = false -- 역방향 플래그
local isStarted = false -- 시작 이벤트 게이트
local initStartPos = nil -- 시작 위치 캐시
local initTargetPos = nil -- 도착 위치 캐시
local posScaleFactor = nil -- 
local addType = true --init pos으로 원복 시키지 않고, cycle이 종료되는 타이밍에 해당 위치를 기준으로 다시 loop를 수행할 수 있게, 이 플레그로 원복가능하게 제어

-- 값을 0~1 범위로 제한.
local function Clamp01(value)
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
end

-- 정수 지수용 pow 대체 함수.
local function Pow(base, exponent)
    -- 지수가 0일 경우 1 반환
    if exponent == 0 then return 1 end
    
    -- 음수 지수 처리
    if exponent < 0 then
        base = 1 / base
        exponent = -exponent
    end

    local result = 1
    while exponent > 0 do
        -- 지수가 홀수일 때
        if exponent % 2 == 1 then
            result = result * base
        end
        base = base * base
        exponent = math.floor(exponent / 2)
    end
    return result
end

-- 선택된 이징 곡선을 적용.
--[[local function ApplyEase(t)
    if this.EaseInSine then
        return 1 - Mathf.Cos((t * math.pi) / 2)
    end
    if this.EaseOutSine then
        return Mathf.Sin((t * math.pi) / 2)
    end
    if this.EaseInOutSine then
        return -(Mathf.Cos(math.pi * t) - 1) / 2
    end
    if this.EaseInCubic then
        return t * t * t
    end
    if this.EaseOutCubic then
        return 1 - Pow(1 - t, 3)
    end
    if this.EaseInOutCubic then
        if t < 0.5 then
            return 4 * t * t * t
        end
        return 1 - Pow(-2 * t + 2, 3) / 2
    end
    return t
end]]--

local function ApplyEase(t)
    if easeInSine then
        return 1 - Mathf.Cos((t * math.pi) / 2)
    end
    if easeOutSine then
        return Mathf.Sin((t * math.pi) / 2)
    end
    if this.EaseInOutSine then
        return -(Mathf.Cos(math.pi * t) - 1) / 2
    end
    if easeInCubic then
        return t * t * t
    end
    if easeOutCubic then
        return 1 - Pow(1 - t, 3)
    end
    if easeInOutCubic then
        if t < 0.5 then
            return 4 * t * t * t
        end
        return 1 - Pow(-2 * t + 2, 3) / 2
    end
    return t
end

-- 현재 t값에 맞춰 위치를 적용.
local function ApplyTween(t)    
    -- addType이 제거되고 두 지점간 위치 이동을 기반으로 이동처리를 할경우 아래의 주석을해제할것
    --if this.FromValue == nil or this.ToValue == nil then return end

    local lerpT = t
    if isReversed then
        lerpT = 1 - lerpT
    end

    -- addType이 제거되고 두 지점간 위치 이동을 기반으로 이동처리를 할경우 아래의 주석을해제할것
    -- local pos = initStartPos + this.FromValue + (this.ToValue - this.FromValue) * lerpT    
    if this.UseOnlyCalculator then
        if this.OnTweenEvent ~= nil then
            local pos = initStartPos + (initTargetPos - initStartPos) * lerpT
            this.OnTweenEvent:Call(pos)
        end 
    else
        if rigidBody ~= nil then            
            local pos = initStartPos + (initTargetPos - initStartPos) * lerpT
            rigidBody:MovePosition(pos)            
        else
            local pos = initStartPos + (initTargetPos - initStartPos) * lerpT
            targetTransform.localPosition = pos
        end
    end
end

-- 레퍼런스를 캐싱하고 AutoStart면 재생.
function this.OnStart()

    serviceApi = this.serviceApi
    script = this.scriptObject
    targetTransform = script.parent.transform
    rigidBody = script.parent:GetComponent("Rigidbody")

    if this.UseOnlyCalculator == false then
        if this.AutoStart then
            this.Play()
        end
    end

end

-- 시간 업데이트, 이징 적용, 루프/왕복 처리.
function this.OnUpdate(deltaTime)
    if isPlaying == false then return end
    if this.Duration < 0 then return end    

    if delayTimer > 0 then
        delayTimer = delayTimer - deltaTime
        if delayTimer > 0 then 
            return 
        end
        delayTimer = 0
    end   

    if isStarted == false then
        isStarted = true
        ApplyTween(0)
        --if this.OnStartEvent ~= nil then
        --    this.OnStartEvent:Call()
        --end
    end

    elapsed = elapsed + deltaTime
    local t = Clamp01(elapsed / this.Duration)
    local easeT = ApplyEase(t)

    ApplyTween(easeT)

    if elapsed >= this.Duration then        
        if this.Loop then
            this.UpdateLoopFinish()
        else
            if this.PingPong then
                this.UpdatePingPong()
            else
                isPlaying = false
                if this.OnFinishEvent ~= nil then
                    this.OnFinishEvent:Call()
                end
            end
        end
    end
end

-- 왕복 사이클 처리와 완료 이벤트를 담당.
function this.UpdatePingPong()
    if this.PingPong == false then return end
    if elapsed < this.CycleDelay and this.CycleDelay > 0 then return end

    isReversed = not isReversed
    delayTimer = this.CycleDelay
    elapsed = 0

    if this.OnFinishEvent ~= nil then
        this.OnFinishEvent:Call()
    end 

    isStarted = false
    
    if isReversed == false then   
        -- loop이건 아니건 상관없다. 어차피 loop아니면 isStart조건을 타지 않음                            
        if this.Loop == false then
            isPlaying = false
        end
    end
end

-- 루프 종료 처리와 지연 설정을 담당.
function this.UpdateLoopFinish()
    local isFinish = false
    if this.PingPong then
        this.UpdatePingPong()
    else
        delayTimer = this.CycleDelay
        isStarted = false
        if this.UseOnlyCalculator == false then
            if addType then                
                if rigidBody ~= nil then
                    initStartPos = rigidBody.position
                    initTargetPos = initStartPos + targetTransform.TransformPoint(this.PositionDelta)
                else
                    initStartPos = targetTransform.localPosition
                    initTargetPos = initStartPos + this.PositionDelta
                end                
            end
        else
            if addType then
                local diffPos = initTargetPos - initStartPos
                initStartPos = initTargetPos
                initTargetPos = initStartPos + diffPos                
            end
        end                   

        isFinish = true
    end

    elapsed = 0            

    if isFinish then                
        if this.OnFinishEvent ~= nil then
            this.OnFinishEvent:Call()
        end
    end
end

__EX_FUNCTION__(this)
-- 재생 시작 및 상태 초기화.
function this.Play()

    initStartPos = targetTransform.localPosition
    initTargetPos = initStartPos + this.PositionDelta
    if rigidBody ~= nil then        
        initStartPos =  this.RealPosition(initStartPos)
        initTargetPos = this.RealPosition(initTargetPos)
    end    
    
    elapsed = 0   
    isReversed = false
    isPlaying = true
    isStarted = false
    delayTimer = 0    

    ApplyTween(0)

end

-- Rigidbody 이동용으로 로컬 좌표를 월드 좌표로 변환.
-- TransformPoint는 변환된 내 로컬좌표계를 0,0,0으로 보고 계산을 하는것이 때문에 내 좌표를 집어 넣게 되면 그 기준점이 틀어지기 때문에 부모 Transform을 찾아서 계산 해주어야 한다.
function this.RealPosition(position)    
    local calcTr = targetTransform
    
    if calcTr == nil then return position end        
    if script.parent.parent ~= nil then
        -- parent parent가 있으면 해당 transform 기준으로 변환.
        calcTr = script.parent.parent.transform
    end
        
    position = calcTr:TransformPoint(position)
    return position
    
end

__EX_FUNCTION__(this, __EX_VARIABLE__.vector3())
-- 재생 시작 및 상태 초기화.
function this.PlayWithInitPos(pos)

    initStartPos = pos
    initTargetPos = initStartPos + this.PositionDelta    
    elapsed = 0   
    isReversed = false
    isPlaying = true
    isStarted = false
    delayTimer = 0    

    ApplyTween(0)

end

__EX_FUNCTION__(this)
-- 재생 중단.
function this.Stop()
    isPlaying = false
end
