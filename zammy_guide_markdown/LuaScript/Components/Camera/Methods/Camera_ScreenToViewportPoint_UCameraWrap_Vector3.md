---
title: ScreenToViewportPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Methods/Camera_ScreenToViewportPoint_UCameraWrap_Vector3
source_path: LuaScript/Components/Camera/Methods/Camera_ScreenToViewportPoint_UCameraWrap_Vector3.html
last_updated: "2026.04.06 오후 02:50"
---

# ScreenToViewportPoint

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 함수는 화면 공간의 위치를 뷰포트 공간으로 변환합니다. 주로 2D 또는 3D 그래픽스에서 화면 좌표를 뷰포트 좌표로 변환할 때 사용됩니다. 이 함수는 입력된 위치에 따라 뷰포트 내의 상대적인 위치를 반환합니다.  

뷰포트 좌표는 (0,0)에서 (1,1) 범위로 정규화된 상대 좌표계로,  

화면의 실제 픽셀 해상도와 관계없이 일정한 비율 기반의 위치를 표현할 수 있습니다.

## 함수

ScreenToViewportPoint(position)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | position | 변환할 화면 공간의 위치 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 입력된 화면 좌표를 (0~1) 범위의 뷰포트 상대 좌표로 변환한 결과입니다. |

## 예제 코드

```lua
local camera = someCamera
local x = someX
local y = someY
-- 화면 중앙 좌표를 뷰포트 좌표로 변환
local viewportPos = camera:ScreenToViewportPoint(Vector3(x, y, 0))

print(string.format("화면 좌표 (%.0f, %.0f)는 뷰포트 좌표 (%.2f, %.2f)로 변환되었습니다.",
        x, y, viewportPos.x, viewportPos.y))
```
