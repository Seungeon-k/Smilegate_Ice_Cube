---
title: SetMinMax
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_SetMinMax_Bounds_Vector3_Vector3
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_SetMinMax_Bounds_Vector3_Vector3.html
last_updated: "2026.04.06 오후 02:59"
---

# SetMinMax

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

SetMinMax 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최솟점([min](../Properties/Bounds_min.md)) 과 최댓점([max](../Properties/Bounds_max.md)) 을 동시에 설정하는 메서드입니다.  

이 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 공간 영역을 정의하는 두 점을 한 번에 지정하며,  

새로운 [min](../Properties/Bounds_min.md)/[max](../Properties/Bounds_max.md) 값에 따라 [center](../Properties/Bounds_center.md)(중심) 와 [extents](../Properties/Bounds_extents.md)(반 크기) 를 자동으로 재계산합니다.

## 함수

SetMinMax(min, max)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | min | [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 새로운 최솟점 |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | max | [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 새로운 최댓점 |

### 반환값

없음

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),
        Vector3(2, 2, 2)  -- size
)

print("기존 min:", bounds.min)
print("기존 max:", bounds.max)

-- 새로운 영역 설정
bounds:SetMinMax(
        Vector3(-3, 1, -2),   -- min
        Vector3(5, 7, 4)      -- max
)

print("새 min:", bounds.min)
print("새 max:", bounds.max)
print("새 center:", bounds.center)
print("새 size:", bounds.size)
```
