---
title: ScreenToWorldPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Methods/Camera_ScreenToWorldPoint_UCameraWrap_Vector3
source_path: LuaScript/Components/Camera/Methods/Camera_ScreenToWorldPoint_UCameraWrap_Vector3.html
last_updated: "2026.04.06 오후 02:50"
---

# ScreenToWorldPoint

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 함수는 화면 공간의 점을 월드 공간으로 변환합니다. 월드 공간은 게임 계층 구조의 최상위에서 정의된 좌표계입니다. 주로 마우스의 x, y 좌표를 사용하여 화면 공간의 위치를 지정하며, 깊이를 위한 z 위치도 필요합니다. 이 z 값은 카메라의 클리핑 평면과 관련이 있습니다.

## 함수

ScreenToWorldPoint(position)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | position | 화면 공간의 위치 (주로 마우스 x, y)와 깊이를 위한 z 위치를 포함합니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 입력된 화면 좌표가 실제 월드 공간에서 대응되는 3D 위치입니다. 반환된 값은 카메라의 시점과 투영 행렬을 기준으로 계산되며, z 값은 카메라에서의 거리(월드 단위)를 유지합니다. |

## 예제 코드

```lua
local x = someX
local y = someY
local camera = Scene:GetMainCamera()

-- 화면 좌표 (x, y)와 깊이 값 10을 월드 좌표로 변환
local worldPos = camera:ScreenToWorldPoint(Vector3(x, y, 10))

print(string.format("화면 좌표 (%.0f, %.0f) → 월드 좌표 (%.2f, %.2f, %.2f)",
        x, y, worldPos.x, worldPos.y, worldPos.z))
```
