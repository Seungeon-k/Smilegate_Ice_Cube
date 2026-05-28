---
title: Intersects
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_Intersects_Bounds_Bounds
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_Intersects_Bounds_Bounds.html
last_updated: "2026.04.06 오후 02:59"
---

# Intersects

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

Intersects 함수는 현재 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)가 다른 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)와 교차(겹침)하고 있는지 여부를 검사하는 메서드입니다.

## 함수

Intersects(bounds)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds) | bounds | 현재 Bounds와 충돌 검사할 다른 Bounds 객체 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 서로의 공간이 교차하면 true, 아니면 false |

## 예제 코드

```lua
local a = Bounds(
        Vector3(0, 0, 0),
        Vector3(4, 4, 4) -- size
)

local b = Bounds(
        Vector3(3, 0, 0),
        Vector3(2, 2, 2)
)

if a:Intersects(b) then
    print("두 Bounds는 교차합니다.")
else
    print("두 Bounds는 서로 떨어져 있습니다.")
end
```
