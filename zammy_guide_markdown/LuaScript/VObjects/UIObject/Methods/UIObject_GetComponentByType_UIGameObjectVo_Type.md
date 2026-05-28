---
title: GetComponentByType
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentByType_UIGameObjectVo_Type
source_path: LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentByType_UIGameObjectVo_Type.html
last_updated: "2026.04.06 오후 03:37"
---

# GetComponentByType

## 객체

> UIObject

## 설명

GetComponentByType 메서드는 type 기준으로 데이터를 조회합니다.  

`GetComponentByType`는 계층 탐색 비용이 발생하므로 초기화 구간에서 캐시해 재사용하면 프레임 부하를 줄일 수 있습니다.  

`GetComponentByType`를 여러 스크립트가 동시에 호출하면 결과가 덮어써질 수 있으므로, 호출 주체를 명확히 분리해 관리하세요.

## 함수

GetComponentByType(type)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `Type` | `type` | `type`는 조회/캐스팅 대상 타입 정보입니다. 기대 타입과 실제 컴포넌트 타입이 다르면 nil이 반환될 수 있으니 후속 nil 검사를 포함하세요. |

### 반환값

`GetComponentByType`의 반환값은 현재 조건에 대한 참/거짓 판정입니다. `true`/`false` 경로를 분리해 후속 처리(재시도/대체 흐름)를 명시하세요.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    local componentType = Collider
    local collider = target:GetComponentByType(componentType)
    if collider == nil then
        this.scriptObject:Log("Collider를 찾지 못했습니다.")
    end
end
```
