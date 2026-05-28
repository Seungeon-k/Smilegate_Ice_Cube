---
title: Cast
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject/Methods/VObject_Cast_VObject_string
source_path: LuaScript/VObjects/VObject/Methods/VObject_Cast_VObject_string.html
last_updated: "2026.04.06 오후 03:37"
---

# Cast

## 객체

> [VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)

## 설명

지정된 타입의 오브젝트로 캐스팅 하여 반환합니다. 해당 오브젝트가 지정된 타입이 아닐 경우 nil을 반환합니다.

## 함수

Cast(typeName)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | typeName | 캐스팅할 오브젝트 타입명 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject) | 캐스팅 된 오브젝트 |

## 예제 코드

```lua
-- 특정 영역에 들어온 오브젝트를 Cast 함수로 캐릭터인지 구분 해서 처음 스폰 위치로 리스폰 시키는 예제

function this.OnTriggerEnter(collider)
    local character = collider.vObject:Cast("Character")
    if character == nil then
        return
    end

    character:Respawn(character.startPlayerSpawnPoint)
end
```
