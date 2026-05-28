---
title: GetRelativePointVelocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_GetRelativePointVelocity_URigidbodyWrap_Vector3
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_GetRelativePointVelocity_URigidbodyWrap_Vector3.html
last_updated: "2026.04.06 오후 02:55"
---

# GetRelativePointVelocity

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 주어진 상대 지점에서 강체의 속도를 반환합니다. `relativePoint`는 강체의 로컬 좌표계에서의 위치를 나타내며, 이 지점에서의 속도를 계산합니다. 이 함수는 물리적 계산에 사용되며, 강체의 움직임을 이해하는 데 유용합니다. 반환되는 속도는 [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형식으로 제공됩니다.

## 함수

GetRelativePointVelocity(relativePoint)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `relativePoint` | 강체의 로컬 좌표계에서의 위치 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 상대 지점에서 강체의 속도 |

## 예제 코드

```lua
local velocity = Rigidbody:GetRelativePointVelocity(relativePoint)
```
