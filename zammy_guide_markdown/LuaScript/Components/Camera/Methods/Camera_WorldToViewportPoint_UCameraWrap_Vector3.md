---
title: WorldToViewportPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Methods/Camera_WorldToViewportPoint_UCameraWrap_Vector3
source_path: LuaScript/Components/Camera/Methods/Camera_WorldToViewportPoint_UCameraWrap_Vector3.html
last_updated: "2026.04.06 오후 02:50"
---

# WorldToViewportPoint

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 함수는 월드 공간의 위치를 뷰포트 공간으로 변환합니다. 뷰포트 공간은 화면의 크기에 따라 상대적인 좌표계를 의미합니다. 이 함수를 사용하여 3D 공간의 객체 위치를 2D 화면 좌표로 변환할 수 있습니다.

입력으로 주어진 위치는 월드 공간에서의 좌표이며, 반환값은 뷰포트 공간에서의 해당 위치입니다. 이 함수는 단일 위치 변환에 사용되며, 여러 위치를 변환할 경우 반복 호출이 필요합니다.

## 함수

WorldToViewportPoint(position)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | position | 월드 공간의 위치 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 월드 공간의 위치가 뷰포트(Viewport) 공간의 좌표로 변환된 결과입니다. x와 y는 0~1 범위의 상대적 위치를 나타내며, z는 카메라로부터의 거리(월드 단위)를 의미합니다. z 값이 0보다 작을 경우, 해당 오브젝트는 카메라의 뒤쪽에 위치합니다. |

## 예제 코드

```lua
local target = someObject
local camera = someCamera

-- 대상 오브젝트의 월드 좌표를 뷰포트 좌표로 변환
local viewportPos = camera:WorldToViewportPoint(target.transform.position)

-- 화면 안에 있는지 판별 (0~1 범위 내 위치)
local isVisible = viewportPos.x >= 0 and viewportPos.x <= 1
        and viewportPos.y >= 0 and viewportPos.y <= 1
        and viewportPos.z > 0

if isVisible then
    print(string.format("오브젝트 '%s' 는 화면 내에 있습니다. (%.2f, %.2f)",
            target.name, viewportPos.x, viewportPos.y))
else
    print(string.format("오브젝트 '%s' 는 화면 밖에 있습니다.", target.name))
end
```
