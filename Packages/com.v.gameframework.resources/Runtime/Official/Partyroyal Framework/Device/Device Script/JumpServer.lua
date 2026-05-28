local this = __CREATOR__.new()

-- transform 접근을 위한 script 캐시
local script

-- 기본 점프 힘(스칼라)
this.JumpForce = __EX_VARIABLE__.float(100)
-- 축별 대체 값(x/y/z), Epsilon 초과 시 적용
this.ReplaceJumpForce = __EX_VARIABLE__.vector3()
this.OnJumpEvent = __EX_VARIABLE__.event(_VOBJECT_.vobject())

-- 캐시 초기화
function this.OnStart()
    script = this.scriptObject
end

-- 부모의 forward 방향을 가져온다(정규화)
local function GetUpVector()
    if script == nil or script.parent == nil then return nil end

    local up = script.parent.transform.up

    -- 길이가 0이면 예외 처리
    if up.magnitude <= Mathf.Epsilon then
        return Vector3(0, 1, 0)
    end

    return up.normalized
end

-- forward 방향을 축별 스케일링한 실제 힘을 만든다
function this.BuildJumpForce()
    if this.JumpForce == nil then return nil end

    local up = GetUpVector()
    if up == nil then return nil end

    -- 기본 스칼라를 축별 벡터로 변환
    local factor = Vector3(this.JumpForce, this.JumpForce, this.JumpForce)
    -- 축별 대체 값이 있으면 우선 적용
    if this.ReplaceJumpForce.x > Mathf.Epsilon then
        factor.x = this.ReplaceJumpForce.x
    end
    if this.ReplaceJumpForce.y > Mathf.Epsilon then
        factor.y = this.ReplaceJumpForce.y
    end
    if this.ReplaceJumpForce.z > Mathf.Epsilon then
        factor.z = this.ReplaceJumpForce.z
    end

    -- 축별 스케일 적용
    up.x = up.x * factor.x
    up.y = up.y * factor.y
    up.z = up.z * factor.z
    return up
end

-- 캐릭터에 점프 힘 적용
function this.ApplyJump(character, hitPos)
    if character == nil then return end

    local force = this.BuildJumpForce()
    if force == nil then return end

    character:BounceAt(force, hitPos, VFramework.ForceMode.Impulse)
end

-- 충돌 시 캐릭터를 찾아 점프 처리
function this.OnCollisionEnter(collision)    
    if collision == nil then return end

    local obj = collision.vObject or collision
    if obj == nil then return end

    local character = obj:Cast("Character")
    if character == nil then return end

    -- 현재는 세부위치를 가져올 필요가 없어 보여서 아래와 같이 정의
    local hitPos = script.parent.transform.position
    this.ApplyJump(character, hitPos)
    if this.OnJumpEvent ~= nil then
        this.OnJumpEvent:Call(obj)
    end
end
