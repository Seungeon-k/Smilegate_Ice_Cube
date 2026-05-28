---
title: GetPointVelocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_GetPointVelocity_URigidbodyWrap_Vector3
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_GetPointVelocity_URigidbodyWrap_Vector3.html
last_updated: "2026.04.06 오후 02:55"
---

# GetPointVelocity

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 전역 공간에서 주어진 지점 `worldPoint`에 대한 강체의 속도를 반환합니다. 이 메서드는 물리적 계산에 사용되며, 주어진 지점에서의 강체의 움직임을 이해하는 데 유용합니다.

## 함수

GetPointVelocity(worldPoint)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `worldPoint` | 전역 공간에서 주어진 지점 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 강체의 속도 |

## 예제 코드

```lua
local velocity = Rigidbody:GetPointVelocity(worldPoint)
```
