---
title: ScreenPointToRay
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Methods/Camera_ScreenPointToRay_UCameraWrap_Vector3
source_path: LuaScript/Components/Camera/Methods/Camera_ScreenPointToRay_UCameraWrap_Vector3.html
last_updated: "2026.04.06 오후 02:50"
---

# ScreenPointToRay

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 함수는 카메라에서 주어진 화면 좌표를 통해 나가는 광선을 반환합니다. 3D 포인트를 입력으로 받아, 해당 포인트가 화면의 픽셀 좌표로 해석됩니다. 화면의 왼쪽 아래 모서리는 (0,0)으로, 오른쪽 위 모서리는 (화면 너비 - 1, 화면 높이 - 1)로 정의됩니다. z 좌표는 무시됩니다.

## 함수

ScreenPointToRay(pos)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | pos | 2D 화면 공간의 픽셀 좌표를 포함하는 3D 포인트입니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Ray](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Ray) | 입력된 화면 좌표를 기준으로 카메라의 시점에서 발사되는 광선 객체입니다. 이 광선은 원점(origin)과 방향(direction) 정보를 포함하며, 주로 충돌 판정(Raycast)에 사용됩니다. |

## 예제 코드

```lua
local serviceApi = this.serviceApi
local physicsService = serviceApi.physicsService
local camera = someCamera

-- 클릭 위치에서 광선 생성
local ray = camera:ScreenPointToRay(Vector3(x, y, 0))

local maxDistance = 10.0
local hit, hitInfo = physicsService:RaycastWithHit(ray, maxDistance)

if hit then
    print("Ray hit object:", hitInfo.collider.name)
else
    print("No object detected in front of player.")
end
```
