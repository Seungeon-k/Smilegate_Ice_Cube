---
title: min
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Properties/Bounds_min
source_path: LuaScript/DataTypes/Bounds/Properties/Bounds_min.html
last_updated: "2026.04.06 오후 02:59"
---

# min

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

min은 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 최솟점(Min Point) 을 나타내는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 값입니다.  

이는 중심점([center](Bounds_center.md))에서 [extents](Bounds_extents.md)를 뺀 위치로 계산되며, [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 “좌측·하단·뒤쪽” 모서리를 의미합니다.

## 프로퍼티 정의

- **이름**: `min`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local bounds = Bounds(
        Vector3(0, 1, 0),
        Vector3(4, 6, 2)  -- size
)

print("center:", bounds.center)
print("extents:", bounds.extents)
print("min:", bounds.min)
-- 출력: (-2, -2, -1)

-- min 값을 변경하려면 반드시 SetMin 사용
bounds:SetMin(Vector3(-5, -3, -2))

print("새로운 center:", bounds.center)
print("새로운 extents:", bounds.extents)
print("새 min:", bounds.min)
```

## 참고 사항

min을 변경하는 올바른 방법은 [SetMin()](../Methods/Bounds_SetMin_Bounds_Vector3.md) 또는 [SetMinMax()](../Methods/Bounds_SetMinMax_Bounds_Vector3_Vector3.md)입니다.
