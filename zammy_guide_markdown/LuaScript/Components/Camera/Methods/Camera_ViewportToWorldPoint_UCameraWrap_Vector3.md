---
title: ViewportToWorldPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Methods/Camera_ViewportToWorldPoint_UCameraWrap_Vector3
source_path: LuaScript/Components/Camera/Methods/Camera_ViewportToWorldPoint_UCameraWrap_Vector3.html
last_updated: "2026.04.06 오후 02:50"
---

# ViewportToWorldPoint

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 함수는 뷰포트 공간의 위치를 월드 공간으로 변환합니다. 뷰포트 공간은 화면의 비율을 기준으로 하며, 이 함수를 사용하여 3D 벡터를 월드 공간으로 변환할 수 있습니다. 이 함수는 주로 카메라의 뷰포트에서 객체의 위치를 계산할 때 사용됩니다.

## 함수

ViewportToWorldPoint(position)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | position | 뷰포트 공간의 3D 벡터입니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 입력된 뷰포트 좌표에 대응하는 실제 월드 공간상의 3D 위치입니다. |

## 예제 코드

```lua
local camera = someCamera

-- 화면 중앙의 뷰포트 좌표 (0.5, 0.5)에서 깊이 10 단위 떨어진 위치 계산
local worldPos = camera:ViewportToWorldPoint(Vector3(0.5, 0.5, 10))


print(string.format("뷰포트 (0.5, 0.5, 10) → 월드 좌표 (%.2f, %.2f, %.2f)",
        worldPos.x, worldPos.y, worldPos.z))
```
