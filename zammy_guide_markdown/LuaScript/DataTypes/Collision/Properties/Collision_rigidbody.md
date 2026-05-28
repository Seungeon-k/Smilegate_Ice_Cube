---
title: rigidbody
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision/Properties/Collision_rigidbody
source_path: LuaScript/DataTypes/Collision/Properties/Collision_rigidbody.html
last_updated: "2026.04.06 오후 02:59"
---

# rigidbody

## 객체

> [Collision](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision)

## 설명

rigidbody는 충돌에 관여한 상대 오브젝트의 [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody) 정보를 나타내는 프로퍼티입니다.  

이 값을 통해 충돌한 물체의 물리 특성(질량, 속도, 회전, 중력 적용 여부 등)에 접근할 수 있으며, 충돌 후 반응 로직이나 힘(Force) 적용, 넉백 처리 등에 활용할 수 있습니다.  

예를 들어, 플레이어가 이동 중 상자를 밀었을 때, 이 프로퍼티를 통해 상자의 [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)에 힘을 가할 수 있습니다.

## 프로퍼티 정의

- **이름**: `rigidbody`
- **타입**: [`Rigidbody`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnCollisionEnter(collision)
    local otherRigidbody = collision.rigidbody

    -- 충돌 대상이 Rigidbody를 가지고 있는 경우
    if otherRigidbody ~= nil then

        print("충돌 대상의 현재 속도:", otherRigidbody.velocity)

        -- 충돌 방향으로 밀어내는 힘을 적용
        local pushForce = collision.relativeVelocity.normalized * 5.0
        otherRigidbody:AddForce(pushForce)
    else
        print("충돌 대상은 Rigidbody를 가지고 있지 않습니다.")
    end
end
```

## 참고 사항

rigidbody는 충돌 대상에 Rigidbody가 존재할 경우에만 유효한 값을 반환하며, 그렇지 않으면 nil을 반환합니다.
