---
title: SetSize
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_SetSize_Bounds_Vector3
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_SetSize_Bounds_Vector3.html
last_updated: "2026.04.06 오후 02:59"
---

# SetSize

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

SetSize 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 전체 크기([size](../Properties/Bounds_size.md)) 를 지정된 값으로 설정하는 메서드입니다.

## 함수

SetSize(value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | value | 새로 지정할 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 전체 크기([size](../Properties/Bounds_size.md)). 각 축별(x, y, z)로 적용됩니다. |

### 반환값

없음

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),      -- center
        Vector3(2, 4, 6)       -- size
)

print("기존 size:", bounds.size)
-- (2,4,6)

-- size를 (10, 2, 6)으로 변경
bounds:SetSize(Vector3(10, 2, 6))

print("새 size:", bounds.size)       -- (10,2,6)
print("새 extents:", bounds.extents) -- (5,1,3)
print("center 유지됨:", bounds.center)
```
