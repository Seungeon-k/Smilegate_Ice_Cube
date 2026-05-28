---
title: AttachPart
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AttachPart_PenguinCharacterVo_WorldG_2EA5A0B519
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AttachPart_PenguinCharacterVo_WorldG_2EA5A0B519.html
last_updated: "2026.04.06 오후 03:34"
---

# AttachPart

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`AttachPart`는 지정한 [`WorldObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject)를 펭귄 캐릭터의 특정 파츠 슬롯(partsType)에 부착합니다.  

부착 시 해당 파츠 슬롯의 트랜스폼 계층에 연결되며, 캐릭터 외형(렌더링)과 함께 동작하도록 구성됩니다.  

모자/장식/장비 등 파츠 오브젝트를 캐릭터에 장착해 외형을 변경하는 용도로 사용합니다.

## 함수

AttachPart(vObject, partsType)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`WorldObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject) | vObject | 캐릭터 파츠 슬롯에 부착할 오브젝트입니다. |
| [`CharacterPartsType`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/CharacterPartsType) | partsType | 부착할 캐릭터 파츠 슬롯 타입입니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.AttachHeadPart(penguin, partObject)
    penguin:AttachPart(partObject, VFramework.CharacterPartsType.LeftWeapon)
end
```
