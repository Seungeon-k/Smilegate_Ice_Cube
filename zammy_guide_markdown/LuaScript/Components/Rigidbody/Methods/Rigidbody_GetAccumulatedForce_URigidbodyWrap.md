---
title: GetAccumulatedForce
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_GetAccumulatedForce_URigidbodyWrap
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_GetAccumulatedForce_URigidbodyWrap.html
last_updated: "2026.04.06 오후 02:54"
---

# GetAccumulatedForce

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 시뮬레이션 단계 이전에 Rigidbody가 누적한 힘을 반환합니다. 이 힘은 물리적 계산에 사용되며, Rigidbody의 상태를 이해하는 데 유용합니다. 반환되는 값은 ForceMode.Force로 표현된 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형식입니다.

## 함수

GetAccumulatedForce()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 다음 FixedUpdate에서 적용될 누적 힘([ForceMode.Force](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) 기준) |

## 예제 코드

```lua
local accumulatedForce = Rigidbody:GetAccumulatedForce()
```
