---
title: AddItem
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddItem_PenguinCharacterVo_Item
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddItem_PenguinCharacterVo_Item.html
last_updated: "2026.04.06 오후 03:34"
---

# AddItem

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

AddItem 함수는 지정된 [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)을 [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)가 획득합니다.  

아이템을 줍는 동작과 동일하게 처리되며, 성공적으로 획득될 경우 [OnPickedUpItem](https://developers-zammysmith.onstove.com/ko/LuaScript/Services/PlayerService/Events/PlayerService_OnPickedUpItem)  

이벤트가 발생합니다.

또한 전달된 [item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)의 출처에 따라 동작이 달라집니다.

- 
  [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)이 Palette에 있는 [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)인 경우  
  

→ 해당 [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)을 새로 생성한 뒤 [Character](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/Character)가 획득합니다.
- 
  [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)이 World에 존재하는[Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)인 경우  
  

→ 월드에 존재하던 해당 [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) 인스턴스를 그대로 획득합니다.

## 함수

AddItem(item)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)가 획득할 아이템. Palette 기반이면 새로 생성되어 지급되며, World 아이템이면 해당 인스턴스를 획득합니다. |

### 반환값

없음

## 예제 코드

```lua
local paletteItem = this.someItem
character:AddItem(paletteItem)
```

## 참고 사항

아이템이 유효하지 않거나 획득이 불가능한 상태이면 아무런 동작을 하지 않습니다.
