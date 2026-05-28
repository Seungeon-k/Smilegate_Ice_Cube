---
title: GetEquippedItem
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetEquippedItem_PenguinCharacterVo
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetEquippedItem_PenguinCharacterVo.html
last_updated: "2026.04.06 오후 03:34"
---

# GetEquippedItem

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

GetEquippedItem은 캐릭터가 현재 장착 중인 아이템을 반환하는 함수입니다.  

장착된 아이템이 없을 경우 nil을 반환합니다.  

주로 장비 상태를 확인하거나 UI에 표시할 때 사용됩니다.

## 함수

GetEquippedItem()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | 현재 캐릭터에 장착된 아이템 객체를 반환합니다. 장착된 아이템이 없을 경우 nil을 반환합니다. |

## 예제 코드

```lua
local equippedItem = character:GetEquippedItem()
```
