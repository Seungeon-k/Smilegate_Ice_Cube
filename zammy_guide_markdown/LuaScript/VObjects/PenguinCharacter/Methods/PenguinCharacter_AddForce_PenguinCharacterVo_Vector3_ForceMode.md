---
title: AddForce
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddForce_PenguinCharacterVo_Vector3_ForceMode
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddForce_PenguinCharacterVo_Vector3_ForceMode.html
last_updated: "2026.04.06 오후 03:34"
---

# AddForce

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

이 함수는 캐릭터에 외부 힘(force)을 가하여 물리적인 반응을 유도합니다.  

AddForce()는 캐릭터의 이동 속도에 직접적인 영향을 주며,  

힘의 크기([Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3))와 적용 방식([ForceMode](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode))에 따라 다른 결과를 나타냅니다.

## 함수

AddForce(force, forceMode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | force | 캐릭터의 작용 되어 질 힘과 방향 값 |
| [ForceMode](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | forceMode | 힘이 작용 되어 질 방법 |

### 반환값

없음

## 예제 코드

```lua
local playerCharacter = someCharacter

-- 위쪽으로 점프하는 힘 적용
local jumpForce = Vector3(0, 8, 0)
playerCharacter:AddForce(jumpForce, VFramework.ForceMode.Impulse)
```
