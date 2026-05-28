---
title: collider
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision/Properties/Collision_collider
source_path: LuaScript/DataTypes/Collision/Properties/Collision_collider.html
last_updated: "2026.04.06 오후 02:59"
---

# collider

## 객체

> [Collision](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision)

## 설명

collider는 현재 충돌(Collision)에 참여한 충돌체(Collider) 객체를 나타내는 프로퍼티입니다.  

이 값을 통해 충돌한 대상의 물리 충돌체 정보(모양, 트리거 여부, 레이어 등)에 접근할 수 있으며,  

특정 충돌 대상의 판정 로직을 구현하거나 반응 처리를 할 때 자주 사용됩니다.

## 프로퍼티 정의

- **이름**: `collider`
- **타입**: [`Collider`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnCollisionEnter(collision)
    local hitCollider = collision.collider

    -- 충돌한 콜라이더 이름 출력
    print("충돌한 Collider 이름:", hitCollider.name)

    -- 충돌체의 트리거 여부 체크
    if hitCollider.isTrigger then
        print("이 충돌체는 트리거입니다.")
    else
        print("일반 충돌체입니다.")
    end
end
```

## 참고 사항

collider는 충돌에 참여한 상대 객체의 [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)를 참조합니다.
