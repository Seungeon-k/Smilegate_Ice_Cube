---
title: IntersectRay
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_IntersectRay_Bounds_Ray
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_IntersectRay_Bounds_Ray.html
last_updated: "2026.04.06 오후 02:59"
---

# IntersectRay

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

IntersectRay 함수는 전달된 Ray(광선) 이 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)와 교차하는지 검사하는 메서드입니다.  

광선이 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 표면을 통과하거나 내부를 향해 진행될 때 교차 여부와 첫 번째 교차 거리(t) 를 반환합니다.

## 함수

IntersectRay(ray)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Ray](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Ray) | ray | 충돌 체크를 수행할 레이 객체입니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| number (선택적) | 첫 번째 교차 지점까지의 거리(t). 교차하지 않을 경우 없음 |
| boolean | 레이가 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)와 교차하면 true, 아니면 false |

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),
        Vector3(4, 4, 4)  -- size
)

local origin = Vector3(-10, 0, 0)
local direction = Vector3(1, 0, 0)
local ray = Ray(origin, direction)

local hit, distance = bounds:IntersectRay(ray)

if hit then
    print("Ray와 Bounds가 교차했습니다. 첫 교차 t:", distance)
else
    print("Ray는 Bounds를 통과하지 않았습니다.")
end
```
