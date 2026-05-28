---
title: SetActive
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject/Methods/VObject_SetActive_VObject_boolean
source_path: LuaScript/VObjects/VObject/Methods/VObject_SetActive_VObject_boolean.html
last_updated: "2026.04.06 오후 03:37"
---

# SetActive

## 객체

> [VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)

## 설명

오브젝트를 활성화 하거나 비활성화 합니다.

## 함수

SetActive(value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| boolean | value | 활성화 여부 |

### 반환값

없음

## 예제 코드

```lua
-- 모든 UI오브젝트를 비활성화 하는 함수 예제

function this.HideAllUI()
    local serviceApi = this.serviceApi
    local rootUIObjects = serviceApi.uiService:GetChildrenUI()
    for i = 1, #rootUIObjects do
        local uiObject = rootUIObjects[i]
        uiObject:SetActive(false)
    end
end
```
