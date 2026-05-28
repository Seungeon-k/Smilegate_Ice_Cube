---
title: GetAccumulatedTorque
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_GetAccumulatedTorque_URigidbodyWrap
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_GetAccumulatedTorque_URigidbodyWrap.html
last_updated: "2026.04.06 오후 02:55"
---

# GetAccumulatedTorque

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 시뮬레이션 단계 이전에 Rigidbody가 축적한 토크를 반환합니다. 이 값은 물리적 시뮬레이션에서 Rigidbody의 회전 운동에 영향을 미치는 힘을 나타냅니다. 이 메서드는 인수를 필요로 하지 않으며, 호출 시 현재 상태의 토크를 반환합니다.

## 함수

GetAccumulatedTorque()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 다음 Physics 에서의 토크(회전력) |

## 예제 코드

```lua
local torque = Rigidbody:GetAccumulatedTorque()
```
