---
title: Get
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_Get_Bounds
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_Get_Bounds.html
last_updated: "2026.04.06 오후 02:59"
---

# Get

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

Get 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 [center](../Properties/Bounds_center.md)(중심점) 와 [size](../Properties/Bounds_size.md)(전체 크기) 를 한 번에 반환하는 유틸리티 메서드입니다.  

[Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)는 내부적으로 [center](../Properties/Bounds_center.md) 와 [extents](../Properties/Bounds_extents.md) 값을 보관하지만,  

Get() 함수는 이를 사용자가 직관적으로 활용할 수 있도록 [center](../Properties/Bounds_center.md)와 [size](../Properties/Bounds_size.md)를 즉시 계산하여 반환합니다.

## 함수

Get()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 중심점([center](../Properties/Bounds_center.md)) |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 전체 크기(size = extents × 2) |

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 1, 0),
        Vector3(4, 2, 6) -- size
)

local center, size = bounds:Get()

print("center:", center) -- (0,1,0)
print("size:", size)     -- (4,2,6)
```
