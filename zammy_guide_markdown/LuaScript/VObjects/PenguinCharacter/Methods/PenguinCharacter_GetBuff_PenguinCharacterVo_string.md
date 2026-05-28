---
title: GetBuff
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetBuff_PenguinCharacterVo_string
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetBuff_PenguinCharacterVo_string.html
last_updated: "2026.04.06 오후 03:34"
---

# GetBuff

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

GetBuff는 지정한 버프 id(buffId)와 일치하는 [`Buff`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo)를 현재 캐릭터에서 찾아 반환합니다.  

해당 id의 버프가 적용되어 있지 않으면 nil을 반환합니다.

## 함수

GetBuff(buffId)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | buffId | 조회 할 [`Buff`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo) 객체의 id |

### 반환값

`GetBuff` 호출 시점에 캐릭터에 적용된 버프 중, buffId와 id가 일치하는 [`Buff`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo)를 반환합니다.  

일치하는 버프가 없으면 nil을 반환합니다.

## 예제 코드

```lua
function this.GetBuff(character, id)
    return character:GetBuff(id)
end
```
