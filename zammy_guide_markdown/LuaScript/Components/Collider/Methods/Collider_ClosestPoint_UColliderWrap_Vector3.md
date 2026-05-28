---
title: ClosestPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Methods/Collider_ClosestPoint_UColliderWrap_Vector3
source_path: LuaScript/Components/Collider/Methods/Collider_ClosestPoint_UColliderWrap_Vector3.html
last_updated: "2026.04.06 오후 02:51"
---

# ClosestPoint

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 함수는 주어진 위치에 가장 가까운 콜라이더의 점을 반환합니다. 사용자는 특정 위치를 입력하여 해당 위치에 가장 가까운 콜라이더의 점을 찾을 수 있습니다. 이 함수는 콜라이더의 형태에 따라 반환되는 점이 달라질 수 있습니다. 예를 들어, 구형 콜라이더의 경우 주어진 위치와 가장 가까운 점은 구의 표면이 될 것입니다. 반환된 점은 항상 콜라이더의 경계 내에 위치합니다.

## 함수

ClosestPoint(point)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `point` | 시작점 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 가장 가까운 콜라이더의 점 |

## 예제 코드

```lua
local closestPoint = collider:ClosestPoint(position)
```
