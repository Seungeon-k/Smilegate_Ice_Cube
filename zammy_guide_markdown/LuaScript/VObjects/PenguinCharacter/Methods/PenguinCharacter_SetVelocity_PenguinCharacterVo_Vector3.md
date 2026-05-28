---
title: SetVelocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetVelocity_PenguinCharacterVo_Vector3
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetVelocity_PenguinCharacterVo_Vector3.html
last_updated: "2026.04.06 오후 03:35"
---

# SetVelocity

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

이 함수는 캐릭터의 현재 속도(velocity)를 직접 설정합니다.  

즉, 캐릭터의 물리 연산이나 이동 로직에 의해 결정되는 속도를 덮어쓰며,  

즉시 특정 방향 및 크기의 속도로 이동하게 만듭니다.

## 함수

SetVelocity(velocity)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | velocity | 적용할 속도 벡터입니다. |

### 반환값

없음

## 예제 코드

```lua
local playerCharacter = someCharacter

-- 앞으로 빠르게 대시시키기
local dashSpeed = 10
local forward = playerCharacter.transform.forward
playerCharacter:SetVelocity(forward * dashSpeed)
```
