---
title: UseItem
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_UseItem_PenguinCharacterVo_Item
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_UseItem_PenguinCharacterVo_Item.html
last_updated: "2026.04.06 오후 03:35"
---

# UseItem

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

UseItem은 캐릭터가 지정된 아이템을 즉시 사용(Activate) 하도록 하는 함수입니다.  

이 함수는 무기 공격, 스킬 발동, 회복 아이템 사용 등 다양한 상황에서 활용됩니다.  

장착이 되어 있지 않는 아이템이면 장착을 먼저 하고 사용되어집니다.

## 함수

UseItem(item)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | item | 캐릭터가 사용할 대상 아이템 객체입니다. 무기, 스킬 아이템, 소비 아이템 등 사용 가능한 아이템이어야 합니다. |

### 반환값

없음

## 예제 코드

```lua
local sword = swordItem
character:UseItem(sword)
```
