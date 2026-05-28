---
title: impulse
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision/Properties/Collision_impulse
source_path: LuaScript/DataTypes/Collision/Properties/Collision_impulse.html
last_updated: "2026.04.06 오후 02:59"
---

# impulse

## 객체

> [Collision](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision)

## 설명

impulse는 충돌이 발생했을 때 물리 엔진이 계산한 충격량(Impulse) 을 나타내는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 값입니다.  

이 값은 충돌 시 물체에 가해진 힘의 크기와 방향을 의미하며, 충돌 강도에 따라 데미지 계산, 반동(넉백), 사운드 효과, 파티클 이펙트 등 다양한 후처리에 활용할 수 있습니다.  

예를 들어, 큰 impulse 값은 강한 충돌(예: 폭발, 낙하 충돌)을 의미합니다.

## 프로퍼티 정의

- **이름**: `impulse`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnCollisionEnter(collision)
    local impact = collision.impulse
    print("충돌 Impulse 벡터:", impact)

    -- 충돌 충격량 크기 계산
    local magnitude = impact.magnitude
    print("충돌 세기:", magnitude)

    -- 강한 충돌일 경우 추가 효과 처리
    if magnitude > 5.0 then
        print("강한 충돌 감지 - 데미지 처리 및 이펙트 출력")
        -- 예: 폭발 이펙트, 넉백 처리 등
    end
end
```

## 참고 사항

impulse 값은 충돌 시점에서의 순간적인 충격량을 나타냅니다.
