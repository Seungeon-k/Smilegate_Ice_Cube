---
title: SetMax
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_SetMax_Bounds_Vector3
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_SetMax_Bounds_Vector3.html
last_updated: "2026.04.06 오후 02:59"
---

# SetMax

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

SetMax 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최댓점(Max Point) 을 지정된 값으로 설정하는 메서드입니다.  

최댓점을 변경하면 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 전체 형태가 유지되도록 [center](../Properties/Bounds_center.md)(중심) 와 [extents](../Properties/Bounds_extents.md)(반 크기) 가 자동으로 다시 계산됩니다.

## 함수

SetMax(value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | value | Bounds의 새로운 최댓점([max](../Properties/Bounds_max.md)) 좌표 |

### 반환값

없음

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),      -- center
        Vector3(4, 4, 4)       -- size
)

print("기존 max:", bounds.max)
-- (2, 2, 2)

-- max를 (5, 3, 1) 로 변경
bounds:SetMax(Vector3(5, 3, 1))

print("새 max:", bounds.max)
print("새 min:", bounds.min)
print("새 center:", bounds.center)
print("새 size:", bounds.size)
```
