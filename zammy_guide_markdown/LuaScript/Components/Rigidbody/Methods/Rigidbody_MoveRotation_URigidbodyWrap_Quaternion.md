---
title: MoveRotation
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_MoveRotation_URigidbodyWrap_Quaternion
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_MoveRotation_URigidbodyWrap_Quaternion.html
last_updated: "2026.04.06 오후 02:55"
---

# MoveRotation

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 Rigidbody의 회전을 지정된 [Quaternion](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)으로 변경합니다. 회전은 물리 엔진에 의해 처리되며, 이 함수를 호출하면 Rigidbody의 현재 회전 상태가 주어진 회전으로 업데이트됩니다. 이 메서드는 물리적 시뮬레이션에 영향을 미치므로, 적절한 시점에 호출하는 것이 중요합니다. 예를 들어, FixedUpdate() 내에서 호출하는 것이 권장됩니다.

## 함수

MoveRotation(rot)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `Quaternion` | `rot` | Rigidbody의 새로운 회전 값 |

### 반환값

없음

## 예제 코드

```lua
Rigidbody:MoveRotation(rot)
```
