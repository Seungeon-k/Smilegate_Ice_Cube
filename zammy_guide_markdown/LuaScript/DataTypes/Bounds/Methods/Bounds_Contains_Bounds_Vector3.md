---
title: Contains
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_Contains_Bounds_Vector3
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_Contains_Bounds_Vector3.html
last_updated: "2026.04.06 오후 02:59"
---

# Contains

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

Contains 함수는 지정된 점(point)이 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds) 내부에 포함되어 있는지 여부를 검사하는 기능을 제공합니다.  

[Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최소점([min](../Properties/Bounds_min.md))과 최대점([max](../Properties/Bounds_max.md))을 기준으로 각 축(x, y, z)에 대해 범위 비교를 수행하며,  

모든 축에서 범위를 만족하면 내부에 존재하는 것으로 판단합니다.

## 함수

Contains(point)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | point | Bounds 내에 포함되는지 확인할 3D 좌표 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 점이 Bounds 내부에 있으면 true, 아니면 false |

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),
        Vector3(4, 4, 4) -- size
)

local p1 = Vector3(1, 1, 1)
local p2 = Vector3(10, 0, 0)

print(bounds:Contains(p1))  -- true
print(bounds:Contains(p2))  -- false

if bounds:Contains(p1) then
    print("p1은 Bounds 내부에 있습니다.")
end
```
