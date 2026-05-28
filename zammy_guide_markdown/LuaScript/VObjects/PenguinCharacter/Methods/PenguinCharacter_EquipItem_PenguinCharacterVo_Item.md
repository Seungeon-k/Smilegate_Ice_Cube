---
title: EquipItem
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_EquipItem_PenguinCharacterVo_Item
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_EquipItem_PenguinCharacterVo_Item.html
last_updated: "2026.04.06 오후 03:34"
---

# EquipItem

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

EquipItem은 캐릭터에게 지정된 아이템을 장착(Equip) 하는 함수입니다.  

장착 가능한 아이템을 캐릭터에 적용하며, 장착 성공 여부를 boolean 값으로 반환합니다.  

이미 다른 아이템이 장착되어 있을 경우 기존 아이템을 해제(UnEquip)하고 새로운 아이템으로 교체될 수 있습니다.

## 함수

EquipItem(item)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | item | 캐릭터에게 장착할 대상 아이템 객체입니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 장착 성공 여부를 반환합니다. 장착에 성공하면 true, 실패하면 false를 반환합니다. |

## 예제 코드

```lua
-- 아이템 장착 예제
local sword = someSwordItem

local result = character:EquipItem(sword)
```
