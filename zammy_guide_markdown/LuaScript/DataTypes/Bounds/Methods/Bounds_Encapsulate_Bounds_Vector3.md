---
title: Encapsulate
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_Encapsulate_Bounds_Vector3
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_Encapsulate_Bounds_Vector3.html
last_updated: "2026.04.06 오후 02:59"
---

# Encapsulate

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

Encapsulate 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)가 지정된 point를 완전히 포함하도록 영역을 확장하는 기능을 제공합니다.  

만약 전달된 점이 현재 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds) 내부에 있다면 아무런 변화가 일어나지 않습니다.  

하지만 점이 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds) 바깥에 있다면,  

[min](../Properties/Bounds_min.md)과 [max](../Properties/Bounds_max.md)를 기준으로 새로 확장된 영역을 계산하여 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 크기([extents](../Properties/Bounds_extents.md))와 중심([center](../Properties/Bounds_center.md))을 자동으로 재조정합니다.

## 함수

Encapsulate(point)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | point | Bounds에 포함되어야 하는 위치(점). 필요시 Bounds가 확장됩니다. |

### 반환값

없음

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),
        Vector3(2, 2, 2) -- size
)

print("초기 min, max:", bounds.min, bounds.max)

local point = Vector3(5, 3, -1)
bounds:Encapsulate(point)

print("확장된 min:", bounds.min)
print("확장된 max:", bounds.max)
print("새 center:", bounds.center)
print("새 size:", bounds.size)
```
