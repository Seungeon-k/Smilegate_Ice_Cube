---
title: SetControlBlocked
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetControlBlocked_PenguinCharacterVo_boolean
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetControlBlocked_PenguinCharacterVo_boolean.html
last_updated: "2026.04.06 오후 03:35"
---

# SetControlBlocked

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

SetControlBlocked는 캐릭터의 플레이어/입력 제어로 인해 발생하는 이동 및 동작을 차단하거나 허용합니다.

## 함수

SetControlBlocked(blocked)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `boolean` | blocked | true면 제어(입력)에 의한 이동/동작을 차단하고, false면 허용합니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.SetControlBlocked(character, block)
    character:SetControlBlocked(block)
end
```
