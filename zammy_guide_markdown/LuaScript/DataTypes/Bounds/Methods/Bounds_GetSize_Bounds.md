---
title: GetSize
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_GetSize_Bounds
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_GetSize_Bounds.html
last_updated: "2026.04.06 오후 02:59"
---

# GetSize

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

GetSize 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 전체 크기([size](../Properties/Bounds_size.md)) 를 반환합니다.

## 함수

GetSize()

### 매개변수

없음

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 전체 크기([size](../Properties/Bounds_size.md)) |

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),        -- center
        Vector3(4, 6, 2)         -- size
)

local size = bounds:GetSize()

print("size:", size)
-- 출력: (4, 6, 2)

-- extents와 비교
print("extents:", bounds.extents)
-- 출력: (2, 3, 1) → size = extents * 2
```
