---
title: center
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Properties/Bounds_center
source_path: LuaScript/DataTypes/Bounds/Properties/Bounds_center.html
last_updated: "2026.04.06 오후 02:59"
---

# center

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

center는 Bounds가 위치하고 있는 중심 좌표([Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)) 를 나타내는 속성입니다.  

이 중심점을 기준으로 [extents](Bounds_extents.md) 값이 더해지고 빼져 [min](Bounds_min.md)과 [max](Bounds_max.md) 영역이 결정됩니다.

즉, Bounds의 위치는 center에 의해 결정되며,  

크기는 [extents](Bounds_extents.md) 또는 [size](Bounds_size.md) 속성에 의해 정의됩니다.

## 프로퍼티 정의

- **이름**: `center`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local bounds = Bounds(Vector3(0, 1, 0), Vector3(2, 2, 2))

print(bounds.center)
-- 출력: (0,1,0)

-- 중심을 이동시키는 방법
bounds.center = Vector3(5, 3, -1)
print("변경된 center:", bounds.center)

-- center 기반 min·max 확인
print("min:", bounds.min)
print("max:", bounds.max)
```

## 참고 사항

center가 변경되면 [min](Bounds_min.md)과 [max](Bounds_max.md)도 자동으로 변경됩니다.
