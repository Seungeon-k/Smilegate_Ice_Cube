---
title: ClosestPointOnBounds
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Methods/Collider_ClosestPointOnBounds_UColliderWrap_Vector3
source_path: LuaScript/Components/Collider/Methods/Collider_ClosestPointOnBounds_UColliderWrap_Vector3.html
last_updated: "2026.04.06 오후 02:51"
---

# ClosestPointOnBounds

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 함수는 부착된 콜라이더의 경계 상자에 가장 가까운 점을 반환합니다. 주어진 위치에서 가장 가까운 경계 점을 찾는 데 사용됩니다. 이 함수는 주로 물리적 충돌 감지 및 경계 계산에 유용합니다. 반환되는 점은 주어진 위치와 경계 상자 간의 최단 거리 지점을 나타냅니다.

## 함수

ClosestPointOnBounds(position)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `position` | 시작점 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 경계 상자에 가장 가까운 점 |

## 예제 코드

```lua
local closestPoint = collider:ClosestPointOnBounds(position)
```
