---
title: GetMax
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_GetMax_Bounds
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_GetMax_Bounds.html
last_updated: "2026.04.06 오후 02:59"
---

# GetMax

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

GetMax 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최댓점(Max Point) 을 반환합니다.  

[max](../Properties/Bounds_max.md)는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 중심점([center](../Properties/Bounds_center.md))에서 반 크기([extents](../Properties/Bounds_extents.md))를 더한 값으로 계산됩니다.

즉, [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 오른쪽 / 위 / 앞 방향으로 가장 멀리 있는 꼭짓점을 의미합니다.

## 함수

GetMax()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최댓점([max](../Properties/Bounds_max.md)) 좌표 |

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),      -- center
        Vector3(4, 6, 2)       -- size
)

local max = bounds:GetMax()
print("max:", max)
-- 출력: (2, 3, 1)  → extents = (2,3,1), center + extents
```
