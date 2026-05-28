---
title: ClosestPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_ClosestPoint_Bounds_Vector3
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_ClosestPoint_Bounds_Vector3.html
last_updated: "2026.04.06 오후 02:59"
---

# ClosestPoint

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

ClosestPoint는 지정된 point에 대해 Bounds 표면 또는 내부에서 가장 가까운 점을 계산하여 반환하는 함수입니다.

## 함수

ClosestPoint(point)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | point | Bounds와 거리 계산을 수행할 대상 위치입니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| number | 해당 점까지의 거리 제곱값(distance squared) |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | Bounds 표면 또는 내부에서 point에 가장 가까운 좌표 |

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),
        Vector3(4, 4, 4) -- size
)

local point = Vector3(5, 2, 0)

local closest, distSqr = bounds:ClosestPoint(point)

print("가장 가까운 점:", closest)
print("거리 제곱값:", distSqr)
```

## 참고 사항

점이 내부에 있으면 distance는 0이며 closestPoint는 입력값과 동일합니다.
