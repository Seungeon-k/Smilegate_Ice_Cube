---
title: GetOwnerCharacter
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Methods/Item_GetOwnerCharacter_ItemVo
source_path: LuaScript/VObjects/ItemVo/Methods/Item_GetOwnerCharacter_ItemVo.html
last_updated: "2026.04.06 오후 03:33"
---

# GetOwnerCharacter

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

GetOwnerCharacter는 해당 아이템을 소유하고 장착하고 있는 캐릭터([Character](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/Character)) 객체를 반환하는 함수입니다.  

이 함수는 아이템이 어떤 캐릭터에 의해 사용되고 있는지를 확인하거나, 해당 캐릭터의 상태/정보를 참조할 때 유용하게 활용됩니다.  

특히 무기, 스킬, 소비 아이템 등 전투나 상호작용이 필요한 아이템 로직에서 자주 사용됩니다.

## 함수

GetOwnerCharacter()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Character](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/Character) | 아이템을 현재 소유하고 있는 캐릭터 객체를 반환합니다. 소유자가 없는 경우 nil을 반환할 수 있습니다. |

## 예제 코드

```lua
local sword = someSwordItem
local owner = sword:GetOwnerCharacter()
```
