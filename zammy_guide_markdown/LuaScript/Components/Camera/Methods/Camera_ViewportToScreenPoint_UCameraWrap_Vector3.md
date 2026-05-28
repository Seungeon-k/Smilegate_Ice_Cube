---
title: ViewportToScreenPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Methods/Camera_ViewportToScreenPoint_UCameraWrap_Vector3
source_path: LuaScript/Components/Camera/Methods/Camera_ViewportToScreenPoint_UCameraWrap_Vector3.html
last_updated: "2026.04.06 오후 02:50"
---

# ViewportToScreenPoint

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 함수는 뷰포트 공간의 위치를 스크린 공간으로 변환합니다. 뷰포트 공간은 화면의 비율을 기준으로 하며, 스크린 공간은 실제 픽셀 좌표를 기준으로 합니다. 이 함수를 사용하여 UI 요소나 게임 오브젝트의 위치를 스크린 좌표로 변환할 수 있습니다.

## 함수

ViewportToScreenPoint(position)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | position | 변환할 뷰포트 위치 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 입력된 뷰포트 좌표를 스크린(Screen) 좌표로 변환한 결과입니다. x, y는 픽셀 단위의 화면 위치를 나타내며, z는 입력된 깊이 값을 그대로 유지합니다. |

## 예제 코드

```lua
local camera = someCamera

-- 화면의 중앙 (0.5, 0.5) 좌표를 스크린 픽셀 좌표로 변환
local screenPos = camera:ViewportToScreenPoint(Vector3(0.5, 0.5, 0))

print(string.format("뷰포트 좌표 (0.5, 0.5)는 스크린 좌표 (%.0f, %.0f)로 변환되었습니다.",
        screenPos.x, screenPos.y))
```
