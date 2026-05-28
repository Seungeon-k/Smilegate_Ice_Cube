---
title: SetMin
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_SetMin_Bounds_Vector3
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_SetMin_Bounds_Vector3.html
last_updated: "2026.04.06 오후 02:59"
---

# SetMin

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

SetMin 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최솟점(Min Point) 을 지정된 값으로 설정하는 메서드입니다.  

최솟점을 변경하면 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 전체 구조가 유지되도록 [center](../Properties/Bounds_center.md)(중심) 와 [extents](../Properties/Bounds_extents.md)(반 크기) 가 자동 재계산됩니다.

## 함수

SetMin(value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | value | 새로운 최솟점([min](../Properties/Bounds_min.md))에 해당하는 좌표 |

### 반환값

없음

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),      -- center
        Vector3(4, 4, 4)       -- size
)

print("기존 min:", bounds.min)
-- 출력: (-2, -2, -2)

-- min을 변경
bounds:SetMin(Vector3(-5, -4, -3))

print("새 min:", bounds.min)
print("새 max:", bounds.max)
print("새 center:", bounds.center)
print("새 size:", bounds.size)
```
