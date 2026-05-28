---
title: SetWorldEnabled
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Methods/Item_SetWorldEnabled_ItemVo_boolean
source_path: LuaScript/VObjects/ItemVo/Methods/Item_SetWorldEnabled_ItemVo_boolean.html
last_updated: "2026.04.06 오후 03:33"
---

# SetWorldEnabled

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

`SetWorldEnabled`는 `enabled` 값을 적용해 [`isActiveInWorld`](../Properties/Item_isActiveInWorld.md) 값을 갱신합니다.  

[`isActiveInWorld`](../Properties/Item_isActiveInWorld.md) 값에 따라 [`Item`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)이 월드에 존재할때 활성화 여부가 결정됩니다.

## 함수

SetWorldEnabled(enabled)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| boolean | enabled | enabled는 true/false 상태 제어 플래그입니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    target:SetWorldEnabled(false)
end
```
