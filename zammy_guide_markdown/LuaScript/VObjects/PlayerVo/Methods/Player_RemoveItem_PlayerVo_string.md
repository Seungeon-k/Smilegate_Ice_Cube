---
title: RemoveItem
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Methods/Player_RemoveItem_PlayerVo_string
source_path: LuaScript/VObjects/PlayerVo/Methods/Player_RemoveItem_PlayerVo_string.html
last_updated: "2026.04.06 오후 03:36"
---

# RemoveItem

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`RemoveItem`은 플레이어가 현재 보유하고 있는 아이템 중, 지정한 `itemId`에 해당하는 아이템을 제거하는 함수입니다.

아이템 제거가 완료되면 관련 상태가 갱신되며, 구현에 따라 장착 해제, 소지 목록 변경, 이벤트 호출 등의 후속 처리가 함께 이루어질 수 있습니다.

주로 보유하거나 장착 상태에서 대상 아이템을 삭제할 때 사용합니다.

## 함수

RemoveItem(itemId)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | itemId | 제거할 대상 아이템의 고유 식별자입니다. |

### 반환값

없음

## 예제 코드

```lua
local paletteItem = this.someItem
 player:RemoveItem(paletteItem.itemId)
```

## 참고 사항

- itemId는 제거할 아이템을 식별할 수 있는 올바른 문자열이어야 합니다.
- 존재하지 않는 itemId를 전달한 경우에는 아무 동작도 하지 않거나, 구현에 따라 제거가 무시될 수 있습니다.
- 서버스크립트에서만 동작을 합니다.
