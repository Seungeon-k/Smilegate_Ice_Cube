---
title: CastByType
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject/Methods/VObject_CastByType_VObject_Type
source_path: LuaScript/VObjects/VObject/Methods/VObject_CastByType_VObject_Type.html
last_updated: "2026.04.06 오후 03:37"
---

# CastByType

## 객체

> VObject

## 설명

`CastByType`는 현재 객체를 지정 타입으로 런타임 캐스팅합니다. 캐스팅 실패 시 nil이 반환될 수 있으므로 사용 전에 타입 검증을 수행하세요.  

`CastByType`는 전달한 타입 메타 정보를 기준으로 현재 객체를 런타임 캐스팅해 반환합니다. 상속 체인에 호환 타입이 없으면 `nil`이 반환되므로, 캐스팅 직후 분기 처리와 대체 경로를 함께 두어야 안전합니다.  

`CastByType`를 여러 스크립트가 동시에 호출하면 결과가 덮어써질 수 있으므로, 호출 주체를 명확히 분리해 관리하세요.

## 함수

CastByType(type)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `Type` | `type` | `type` 입력값입니다. |

### 반환값

`CastByType`의 반환값은 현재 조건에 대한 참/거짓 판정입니다. `true`/`false` 경로를 분리해 후속 처리(재시도/대체 흐름)를 명시하세요.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    local casted = target:CastByType(Character)
    if casted ~= nil then
        this.scriptObject:Log("Character 타입 캐스팅 성공")
    end
end
```
