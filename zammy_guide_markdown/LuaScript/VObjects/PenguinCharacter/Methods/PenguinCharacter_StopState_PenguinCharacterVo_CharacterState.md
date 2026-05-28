---
title: StopState
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_StopState_PenguinCharacterVo_CharacterState
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_StopState_PenguinCharacterVo_CharacterState.html
last_updated: "2026.04.06 오후 03:35"
---

# StopState

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

이 함수는 캐릭터의 현재 상태(CharacterState)를 중단(정지)시키는 기능을 수행합니다.  

StopState는 캐릭터가 특정 행동을 수행 중일 때  

해당 상태를 강제로 종료하고 기본 상태로 복귀하도록 합니다.

## 함수

StopState(state)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [CharacterState](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/CharacterState) | state | 중단(정지)시키는 캐릭터 기능 |

### 반환값

없음

## 예제 코드

```lua
local character = someCharacter

character:StopState(VFramework.CharacterState.Jump)
```
