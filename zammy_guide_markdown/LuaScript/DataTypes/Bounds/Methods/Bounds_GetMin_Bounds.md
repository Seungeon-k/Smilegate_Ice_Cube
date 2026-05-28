---
title: GetMin
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_GetMin_Bounds
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_GetMin_Bounds.html
last_updated: "2026.04.06 오후 02:59"
---

# GetMin

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

GetMin 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최솟점(Min Point) 을 반환합니다.  

최솟점은 중심점([center](../Properties/Bounds_center.md))에서 반 크기([extents](../Properties/Bounds_extents.md))를 뺀 위치로 계산되며,  

[Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 “왼쪽 · 아래 · 뒤쪽” 끝 좌표를 의미합니다.

## 함수

GetMin()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최솟점([min](../Properties/Bounds_min.md)) 좌표 |

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),      -- center
        Vector3(4, 6, 2)       -- size
)

local min = bounds:GetMin()

print("min:", min)
-- 출력: (-2, -3, -1)  → extents = (2,3,1), center - extents
```
