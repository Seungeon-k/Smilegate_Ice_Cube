---
title: transform
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision/Properties/Collision_transform
source_path: LuaScript/DataTypes/Collision/Properties/Collision_transform.html
last_updated: "2026.04.06 오후 02:59"
---

# transform

## 객체

> [Collision](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision)

## 설명

transform은 충돌에 관여한 상대 오브젝트의 [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform) 정보를 나타내는 프로퍼티입니다.  

이 값을 통해 충돌 대상의 위치(position), 회전(rotation), 크기(scale) 등에 접근할 수 있으며,  

충돌 후 오브젝트의 상태를 파악하거나 후속 동작(넉백, 이펙트 생성 위치 계산 등)에 활용할 수 있습니다.  

collider나 rigidbody와 함께 자주 사용되는 기본적인 참조 속성입니다.

## 프로퍼티 정의

- **이름**: `transform`
- **타입**: [`Transform`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnCollisionEnter(collision)
    local hitTransform = collision.transform

    -- 충돌한 오브젝트의 위치 출력
    print("충돌 대상 위치:", hitTransform.position)

    -- 충돌 대상의 회전 정보 출력
    print("충돌 대상 회전:", hitTransform.rotation)


    -- 충돌 지점을 기준으로 방향 계산 후 반응 처리
    local direction = (hitTransform.position - player.transform.position).normalized
    print("충돌 방향:", direction)
end
```

## 참고 사항

transform은 충돌 대상의 [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform) 컴포넌트를 반환하며, 이를 통해 오브젝트의 공간 정보를 손쉽게 얻을 수 있습니다.  
  

rigidbody가 존재하지 않는 정적 오브젝트라 하더라도 transform은 항상 유효합니다.
