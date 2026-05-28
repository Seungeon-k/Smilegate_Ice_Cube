---
title: IsItemInUse
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_IsItemInUse_PenguinCharacterVo
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_IsItemInUse_PenguinCharacterVo.html
last_updated: "2026.04.06 오후 03:34"
---

# IsItemInUse

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

IsItemInUse는 캐릭터가 현재 어떤 아이템을 사용 중인지 여부를 반환하는 함수입니다.  

캐릭터가 장착 중인 아이템을 활성 상태로 사용하고 있는 경우 true를 반환하며, 아무 아이템도 사용 중이 아닐 경우 false를 반환합니다.  

이 함수를 활용하면 중복 사용 방지, 쿨다운 관리 등의 로직을 쉽게 구현할 수 있습니다.

## 함수

IsItemInUse()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 캐릭터가 현재 아이템을 사용 중이면 true, 사용 중이 아니라면 false를 반환합니다. |

## 예제 코드

```lua
if character:IsItemInUse() then
    -- 캐릭터가 아이템을 사용 중입니다.
else
    -- 캐릭터가 아이템을 사용하고 있지 않습니다.
end
```

## 참고 사항

이 함수는 캐릭터가 어떤 아이템을 사용 중인지는 반환하지 않고, 사용 상태만 반환합니다.

현재 아이템 사용 중이라면 추가 입력이나 스킬 발동을 막는 등의 제어 로직에 자주 사용됩니다.

현재 사용 중인 아이템이 무엇인지 확인하려면 [GetEquippedItem](PenguinCharacter_GetEquippedItem_PenguinCharacterVo.md) 함수를 함께 사용하는 것이 일반적입니다.
