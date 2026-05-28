---
title: size
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Properties/Bounds_size
source_path: LuaScript/DataTypes/Bounds/Properties/Bounds_size.html
last_updated: "2026.04.06 오후 02:59"
---

# size

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

size는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 전체 크기(폭·높이·깊이) 를 나타내는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 값입니다.

## 프로퍼티 정의

- **이름**: `min`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),
        Vector3(4, 6, 2) -- size
)

print("size:", bounds.size)
-- 출력: (4, 6, 2)

-- extents 확인
print("extents:", bounds.extents)
-- (2, 3, 1)

-- size 변경 (SetSize 사용)
bounds:SetSize(Vector3(10, 2, 2))

print("변경된 size:", bounds.size)
print("변경된 extents:", bounds.extents)
```

## 참고 사항

size는 내부에 저장되는 값이 아니라 [extents](Bounds_extents.md)를 기반으로 계산되는 읽기 전용 속성입니다.

[Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 크기를 변경하려면 반드시 [SetSize()](../Methods/Bounds_SetSize_Bounds_Vector3.md)를 사용해야 합니다.
