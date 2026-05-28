---
title: extents
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Properties/Bounds_extents
source_path: LuaScript/DataTypes/Bounds/Properties/Bounds_extents.html
last_updated: "2026.04.06 오후 02:59"
---

# extents

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

extents는 Bounds의 반 크기(Half Size) 를 나타내는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 값입니다.

## 프로퍼티 정의

- **이름**: `extents`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),
        Vector3(4, 6, 2)  -- size
)

print("extents:", bounds.extents)
-- 출력: (2,3,1)  -- size의 절반

-- extents를 조정해 크기 변경
bounds.extents.x = 5
bounds.extents.y = 1
bounds.extents.z = 1

print("새로운 size:", bounds.size)
-- size = extents * 2 → (10,2,2)
```
