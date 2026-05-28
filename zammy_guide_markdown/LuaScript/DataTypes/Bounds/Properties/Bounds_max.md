---
title: max
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Properties/Bounds_max
source_path: LuaScript/DataTypes/Bounds/Properties/Bounds_max.html
last_updated: "2026.04.06 오후 02:59"
---

# max

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

max는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최댓점(Max Point) 을 나타내는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 값입니다.  

이는 중심점([center](Bounds_center.md))에서 [extents](Bounds_extents.md)를 더한 위치로 계산되며, [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 “우측·상단·앞쪽” 모서리를 의미합니다.

## 프로퍼티 정의

- **이름**: `max`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local bounds = Bounds(
        Vector3(0, 1, 0),
        Vector3(4, 6, 2)     -- size
)

print("center:", bounds.center)
print("extents:", bounds.extents)
print("max:", bounds.max)
-- 출력: (2, 4, 1)

-- max를 변경하고 싶다면 SetMax를 사용해야 함
bounds:SetMax(Vector3(5, 5, 5))

print("변경된 center:", bounds.center)
print("변경된 extents:", bounds.extents)
print("새 max:", bounds.max)
```

## 참고 사항

값을 직접 설정하려면 반드시 [SetMax()](../Methods/Bounds_SetMax_Bounds_Vector3.md)를 사용해야 합니다.
