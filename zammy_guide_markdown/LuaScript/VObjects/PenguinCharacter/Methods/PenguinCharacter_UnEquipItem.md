---
title: UnEquipItem
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_UnEquipItem
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_UnEquipItem.html
last_updated: "2026.04.06 오후 03:35"
---

# UnEquipItem

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`UnEquipItem`은 캐릭터에 장착되어 있는 아이템을 해제(UnEquip) 하는 함수입니다.  

이 함수는 주로 무기 교체, 장비 변경, 상태 초기화 등의 상황에서 사용됩니다.  

지정한 아이템이 현재 캐릭터에 장착되어 있는 경우만 해제 동작이 수행됩니다.  

`destroy`는 선택 매개변수이며, 생략하면 UnEquipItem(item) 형태로 호출할 수 있습니다.

## 함수

UnEquipItem(item)  
  

UnEquipItem(item, destroy)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Item`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | `item` | 캐릭터에서 해제할 대상 아이템입니다. 현재 장착 중인 아이템과 일치해야 해제됩니다. |
| `bool` | `destroy` | true인 경우, 해제와 동시에 해당 아이템(오브젝트)을 제거합니다. false인 경우, 장착만 해제하며 아이템 인스턴스는 유지됩니다. |

### 반환값

없음

## 예제 코드

```lua
-- 아이템 해제 예제
local sword = someSwordItem

character:UnEquipItem(sword)
```
