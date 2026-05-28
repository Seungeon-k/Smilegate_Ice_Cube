---
title: WorldToScreenPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Methods/Camera_WorldToScreenPoint_UCameraWrap_Vector3
source_path: LuaScript/Components/Camera/Methods/Camera_WorldToScreenPoint_UCameraWrap_Vector3.html
last_updated: "2026.04.06 오후 02:50"
---

# WorldToScreenPoint

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 함수는 월드 공간의 위치를 스크린 공간으로 변환합니다. 주어진 위치를 스크린 좌표로 변환하여 반환합니다. 이 함수는 주로 3D 객체의 위치를 2D 화면 좌표로 변환할 때 사용됩니다. 반환된 스크린 좌표는 화면의 픽셀 단위로 표현됩니다.

## 함수

WorldToScreenPoint(position)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | position | 변환할 월드 공간의 위치 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 월드 공간의 3D 위치가 화면(Screen) 공간의 픽셀 좌표로 변환된 결과입니다. |

## 예제 코드

```lua
local camera = someCamera
local target = someObject

-- 대상 오브젝트의 월드 위치를 스크린 픽셀 좌표로 변환
local screenPos = camera:WorldToScreenPoint(target.transform.position)


print(string.format("오브젝트 '%s' 의 화면 위치: (%.0f, %.0f)",
        target.name, screenPos.x, screenPos.y))
```
