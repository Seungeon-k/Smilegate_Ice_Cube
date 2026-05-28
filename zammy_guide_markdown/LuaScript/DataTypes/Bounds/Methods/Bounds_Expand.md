---
title: Expand
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds/Methods/Bounds_Expand
source_path: LuaScript/DataTypes/Bounds/Methods/Bounds_Expand.html
last_updated: "2026.04.06 오후 02:59"
---

# Expand

## 객체

> [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)

## 설명

Expand 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 크기를 지정된 값만큼 확장(또는 축소) 하는 기능을 제공합니다.  

확장은 중심점([center](../Properties/Bounds_center.md))을 기준으로 양쪽 방향으로 동일하게 증가하며,  

각 축을 amount 값만큼 개별적으로 확장합니다.

Expand 함수는 [Bounds](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)의 크기를 지정된 값만큼 확장(또는 축소) 하는 기능을 제공합니다.  

확장은 중심점([center](../Properties/Bounds_center.md))을 기준으로 양쪽 방향으로 동일하게 증가하며,  

모든 축(x, y, z)을 amount 양만큼 확장합니다.

## 함수

Expand(amount)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) `number` | `amount` | 각 축을 개별적으로 확장 모든 축을 동일한 값으로 확장 |

### 반환값

없음

## 예제 코드

```lua
local bounds = Bounds(
        Vector3(0, 0, 0),
        Vector3(2, 2, 2)  -- size
)

print("초기 size:", bounds.size)

-- 전체 축을 동일하게 확장
bounds:Expand(4)
print("확장 후 size:", bounds.size)
-- 결과: (6,6,6)  (2 + 4 = 6)
```
