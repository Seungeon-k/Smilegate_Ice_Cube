---
title: vObject
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision/Properties/Collision_vObject
source_path: LuaScript/DataTypes/Collision/Properties/Collision_vObject.html
last_updated: "2026.04.06 오후 02:59"
---

# vObject

## 객체

> [Collision](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Collision)

## 설명

vObject는 충돌에 관여한 상대 오브젝트의 [VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)를 나타내는 프로퍼티입니다.  

[VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)는 게임 내 오브젝트의 기본 단위로, 오브젝트 이름, 활성 상태, 스크립트 접근 등 다양한 정보를 포함합니다.  

이를 통해 충돌한 대상의 성격을 파악하거나 특정 스크립트 로직에 직접 접근할 수 있어, 충돌 후 처리를 보다 유연하게 구현할 수 있습니다.

## 프로퍼티 정의

- **이름**: `vObject`
- **타입**: [`VObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnCollisionEnter(collision)
    local hitObject = collision.vObject


    -- 충돌 대상의 이름 출력
    print("충돌 대상 오브젝트 이름:", hitObject.name)


end
```
