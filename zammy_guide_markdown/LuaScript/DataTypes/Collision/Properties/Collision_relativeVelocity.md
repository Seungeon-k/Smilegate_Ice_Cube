---
title: relativeVelocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision/Properties/Collision_relativeVelocity
source_path: LuaScript/DataTypes/Collision/Properties/Collision_relativeVelocity.html
last_updated: "2026.04.06 오후 02:59"
---

# relativeVelocity

## 객체

> [Collision](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision)

## 설명

relativeVelocity는 충돌이 발생했을 때 충돌한 두 객체 사이의 상대 속도를 나타내는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 값입니다.  

이는 충돌 순간에 두 물체가 서로 얼마나 빠르게 접근하거나 멀어지고 있었는지를 나타내며, 충돌 강도를 계산하거나 반응 방향을 결정하는 데 매우 유용합니다.  

특히 충돌 속도를 기준으로 넉백 처리, 이펙트 강도 조절, 충돌 사운드 볼륨 등을 결정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `relativeVelocity`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnCollisionEnter(collision)
    local relVel = collision.relativeVelocity
    print("상대 속도 벡터:", relVel)

    -- 상대 속도의 크기 계산
    local speed = relVel.magnitude
    print("충돌 속도:", speed)

    -- 충돌 속도가 일정 값 이상이면 충돌 이펙트 재생
    if speed > 3.0 then
        print("강한 충돌! 이펙트를 재생합니다.")
        -- 예: 폭발 효과, 충돌음 볼륨 증가 등
    end
end
```

## 참고 사항

relativeVelocity는 충돌 시점에서의 상대 속도를 나타내며, 충돌에 관여한 두 물체의 속도 차를 기준으로 계산됩니다.
