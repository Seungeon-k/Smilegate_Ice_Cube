---
title: HasBuff
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_HasBuff_PenguinCharacterVo_string
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_HasBuff_PenguinCharacterVo_string.html
last_updated: "2026.04.06 오후 03:34"
---

# HasBuff

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`HasBuff`는 현재 캐릭터에 지정한 버프 ID(buffId)의 [`Buff`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo)가 적용되어 있는지 여부를 확인합니다.

## 함수

HasBuff(buffId)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | buffId | 확인할 버프의 id |

### 반환값

`HasBuff`의 반환값은 현재 조건에 대한 참/거짓 판정입니다. 해당 id의 버프가 적용되어 있으면 true, 적용되어 있지 않으면 false 입니다.

## 예제 코드

```lua
function this.CheckBuff(character)
    if character:HasBuff("buffId") then
        -- 버프가 있을 때 처리
    else
        -- 버프가 없을 때 처리
    end
end
```
