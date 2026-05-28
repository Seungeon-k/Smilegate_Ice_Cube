local this = __CREATOR__.new() -- 진자 트윈 스크립트

local serviceApi -- 서비스 캐시
local script -- 스크립트 오브젝트 캐시
local targetTransform -- 대상 트랜스폼 캐시

this.AutoStart = __EX_VARIABLE__.bool(true) -- 자동 시작
this.SwingDuration = __EX_VARIABLE__.float(2.0) -- 편도 이동 시간
this.PlayDuration = __EX_VARIABLE__.float(999999.0) -- 총 재생 시간
this.InitializeAngle = __EX_VARIABLE__.float(0.0) -- 시작 각도
this.HalfSwingAngle = __EX_VARIABLE__.float(30.0) -- 스윙 각도
this.StartClockwise = __EX_VARIABLE__.bool(true) -- 시작 방향
--this.UseAxisX = __EX_VARIABLE__.bool(false) -- 회전축x
--this.UseAxisY = __EX_VARIABLE__.bool(true) -- 회전축y
--this.UseAxisZ = __EX_VARIABLE__.bool(false) -- 회전축z
local useAxisX = true
local useAxisY = false
local useAxisZ = false

-- this.EaseInSine = __EX_VARIABLE__.bool(false) -- 사인 In 이징
-- this.EaseOutSine = __EX_VARIABLE__.bool(false) -- 사인 Out 이징
-- this.EaseInOutSine = __EX_VARIABLE__.bool(false) -- 사인 InOut 이징
-- this.EaseInCubic = __EX_VARIABLE__.bool(false) -- 큐빅 In 이징
-- this.EaseOutCubic = __EX_VARIABLE__.bool(false) -- 큐빅 Out 이징
-- this.EaseInOutCubic = __EX_VARIABLE__.bool(false) -- 큐빅 InOut 이징
local easeInSine = false -- 사인 In 이징
local easeOutSine = false -- 사인 Out 이징
local easeInOutSine = true -- 사인 InOut 이징
local easeInCubic = false -- 큐빅 In 이징
local easeOutCubic = false -- 큐빅 Out 이징
local easeInOutCubic = false -- 큐빅 InOut 이징
local eashInOutQuad = true -- InOutQuad

--this.OnStartEvent = __EX_VARIABLE__.event() -- 시작 이벤트
this.OnFinishEvent = __EX_VARIABLE__.event() -- 종료 이벤트

local rotationAxis = nil -- 회전 축
local elapsedTotal = 0 -- 전체 경과 시간
local elapsedSegment = 0 -- 구간 경과 시간
local isPlaying = false -- 재생 상태
local isStarted = false -- 시작 처리 여부
local isReversed = false -- 방향 플래그
local isCompleteRequested = false -- 종료 요청 플래그
local baseRotation = nil -- 기준 로컬 회전
local startAngle = 0 -- 구간 시작 각도
local targetAngle = 0 -- 구간 목표 각도
local minAngle = 0 -- 최소 각도
local maxAngle = 0 -- 최대 각도
local segmentDuration = 0 -- 구간 시간

-- 0~1 범위로 값 제한
local function Clamp01(value)
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
end

-- 거듭제곱 계산
local function Pow(base, exponent)
    if exponent == 0 then return 1 end

    if exponent < 0 then
        base = 1 / base
        exponent = -exponent
    end

    local result = 1
    while exponent > 0 do
        if exponent % 2 == 1 then
            result = result * base
        end
        base = base * base
        exponent = Mathf.Floor(exponent / 2)
    end
    return result
end

-- 이징 적용
local function ApplyEase(t)
    if easeInSine then
        return 1 - Mathf.Cos((t * Mathf.PI) / 2)
    end
    if easeOutSine then
        return Mathf.Sin((t * Mathf.PI) / 2)
    end
    if easeInOutSine then
        return -(Mathf.Cos(Mathf.PI * t) - 1) / 2
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
    if eashInOutQuad then
        return (t < 0.5) and (2 * t * t) or (1 - ((-2 * t + 2) ^ 2) / 2)
    end
    return t
end

-- 회전 축 보정
local function GetAxis()
    if useAxisX then return Vector3(1,0,0) end
    if useAxisY then return Vector3(0,1,0) end
    if useAxisZ then return Vector3(0,0,1) end
    return Vector3(0,1,0)    
end

-- 회전 적용
local function ApplyTween(t)
    if targetTransform == nil then return end

    local lerpT = t
    if isReversed then
        lerpT = 1 - lerpT
    end

    local angle = startAngle + (targetAngle - startAngle) * lerpT
    targetTransform.localRotation = baseRotation * Quaternion.AngleAxis(angle, rotationAxis)
end

-- 구간 전환 설정
local function SetSegment(nextTargetAngle)
    startAngle = targetAngle
    targetAngle = nextTargetAngle
    elapsedSegment = 0

    local startIsInit = Mathf.Abs(startAngle - this.InitializeAngle) <= Mathf.Epsilon
    local targetIsInit = Mathf.Abs(targetAngle - this.InitializeAngle) <= Mathf.Epsilon
    if startIsInit or targetIsInit then
        segmentDuration = this.SwingDuration * 0.5
    else
        segmentDuration = this.SwingDuration
    end
end

-- 초기화 처리
function this.OnStart()
    rotationAxis = GetAxis()
    serviceApi = this.serviceApi
    script = this.scriptObject
    targetTransform = script.parent.transform
    

    if this.AutoStart then
        this.Play()
    end

end

-- 프레임 업데이트
function this.OnUpdate(deltaTime)
    if isPlaying == false then return end
    if this.SwingDuration <= 0 then return end
    if this.PlayDuration < 0 then return end

    elapsedTotal = elapsedTotal + deltaTime

    if isStarted == false then
        isStarted = true
        ApplyTween(0)
    end

    elapsedSegment = elapsedSegment + deltaTime
    local t = Clamp01(elapsedSegment / segmentDuration)
    local easeT = ApplyEase(t)    

    ApplyTween(easeT)

    if elapsedTotal >= this.PlayDuration then
        if isCompleteRequested == false then
            isCompleteRequested = true
            script:Log("Change To Complete State")
        end       
    end

    if elapsedSegment >= segmentDuration then
        if isCompleteRequested then
            local targetIsInit = Mathf.Abs(targetAngle - this.InitializeAngle) <= Mathf.Epsilon
            if not targetIsInit then
                SetSegment(this.InitializeAngle)
                return
            end

            isPlaying = false
            if this.OnFinishEvent ~= nil then
                this.OnFinishEvent:Call()
            end
            return
        end

        if targetAngle == maxAngle then
            SetSegment(minAngle)
        elseif targetAngle == minAngle then
            SetSegment(maxAngle)
        else
            SetSegment(maxAngle)
        end
    end
end

__EX_FUNCTION__(this)
-- 재생 시작
function this.Play()
    baseRotation = targetTransform.localRotation
    elapsedTotal = 0
    elapsedSegment = 0
    isPlaying = true
    isStarted = false
    isCompleteRequested = false

    local direction = this.StartClockwise and -1 or 1
    minAngle = this.InitializeAngle - this.HalfSwingAngle
    maxAngle = this.InitializeAngle + this.HalfSwingAngle
    targetAngle = this.InitializeAngle
    startAngle = this.InitializeAngle

    if direction < 0 then
        SetSegment(minAngle)
    else
        SetSegment(maxAngle)
    end

    ApplyTween(0)
end

__EX_FUNCTION__(this)
-- 재생 중지
function this.Stop()
    isPlaying = false
end
