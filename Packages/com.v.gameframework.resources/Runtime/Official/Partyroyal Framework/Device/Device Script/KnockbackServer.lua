local this = __CREATOR__.new()

local serviceApi
local script
local world
local physicsService

-- 범위 넉백 사용 여부
this.UseKnockbackRange = __EX_VARIABLE__.bool(false)
-- 범위 넉백 반경www
this.KnockbackRange = __EX_VARIABLE__.float(5.0)
-- 기본 넉백 힘(스칼라)
this.KnockbackForce = __EX_VARIABLE__.float(20)
-- 넉백 방향에 대한 x축 회전값
this.KnockbackAngle = __EX_VARIABLE__.float(45.0)
-- 넉백 MaxSpeed
--this.KnockbackMaxSpeed = __EX_VARIABLE__.float(0)
local knockbackMaxSpeed = 80

-- 내부 이벤트 모드 여부
local isInternalEventMode = true
-- 짧게 연속 knockback상태를 막기 위한 interval체크용
local immuneKnockbackPlayerIds = {}
local immuneKnockbackDuration = 0.2

-- 서비스 캐시 초기화
function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject

    world = serviceApi.world
    physicsService = serviceApi.physicsService
end

__EX_FUNCTION__(this, _VOBJECT_.vobject())
-- 외부 호출용 넉백 처리
function this.KnockbackAround(collideVObj)

    if isInternalEventMode then
        script:Log("[knockback] use self collision event")
        return
    end

    this.HandleCollide(collideVObj)
end

-- 충돌 대상 처리
function this.HandleCollide(collideVObj)
    if physicsService == nil then
        script:Log("[knockback] phsyics is nil")
        return
    end

    if collideVObj == nil then
        script:Log("[knockback] collideVObj is nil")
        return
    end

    local originPos = script.parent.transform.position

    if this.UseKnockbackRange then
        local colliders = physicsService:OverlapSphere(originPos, this.KnockbackRange)
        for i = 1, #colliders do
            local v = colliders[i]
            local go = v.vObject
            if go ~= nil and go ~= script.parent then
                local character = go:Cast("Character")
                if character ~= nil then
                    this.CollideKnockback(character, originPos)
                end
            end
        end
    else
        local charObj = collideVObj:Cast("Character")
        if charObj == nil then return end

        this.CollideKnockback(charObj, originPos)
    end
end

-- 넉백 힘 계산 및 적용
function this.CollideKnockback(characterObj, hitPos)

    if this.IsImmuneState(characterObj) then
        return
    end

    local targetPos = characterObj.transform.position
    local force = Vector3(this.KnockbackForce, this.KnockbackForce, this.KnockbackForce)
    local diff = targetPos - hitPos
    diff.y = 0.0
    local forward = Vector3.Normalize(diff)    
    --local forward = characterObj.transform.forward * -1.0    

    local xAxis = Vector3.Cross(Vector3.up, forward)    
    forward = forward * Quaternion.AngleAxis(this.KnockbackAngle * -1.0, xAxis)    
    
    force.x = force.x * forward.x    
    force.y = force.y * forward.y
    force.z = force.z * forward.z        

    script:Log("Knockback!!"..tostring(characterObj.player.id))
    this.ChangeImmuneState(characterObj)
    characterObj:KnockBack(force, VFramework.ForceMode.Impulse, knockbackMaxSpeed)
end

-- 내부 이벤트 모드 해제
function this.ChangeDisableInternalMode()
    isInternalEventMode = false
end

-- 충돌 이벤트 처리
function this.OnCollisionEnter(collision)

    if isInternalEventMode == false then return end
    if collision == nil then return end

    local obj = collision.vObject or collision
    if obj == nil then return end

    local character = obj:Cast("Character")
    if character == nil then return end

    local hitPos = obj.transform.position
    this.HandleCollide(character, hitPos)

end

function this.ChangeImmuneState(characterObj)
    if characterObj == nil then
        return false
    end

    if characterObj.player == nil then
        return false
    end

    immuneKnockbackPlayerIds[characterObj.player.id] = immuneKnockbackDuration
end

function this.IsImmuneState(characterObj)
    if characterObj == nil then
        return false
    end

    if characterObj.player == nil then
        return false
    end

    local remainTime = immuneKnockbackPlayerIds[characterObj.player.id]
    if remainTime == nil then
        return false
    end

    return remainTime > 0.0
end

function this.OnUpdate(deltaTime)
    for id, time in pairs(immuneKnockbackPlayerIds) do
        if time ~= nil then
            if time > 0.0 then
                time = time - deltaTime
                immuneKnockbackPlayerIds[id] = time
            end
        end
    end
end