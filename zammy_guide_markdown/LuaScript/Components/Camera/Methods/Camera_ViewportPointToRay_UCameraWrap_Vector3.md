---
title: ViewportPointToRay
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Methods/Camera_ViewportPointToRay_UCameraWrap_Vector3
source_path: LuaScript/Components/Camera/Methods/Camera_ViewportPointToRay_UCameraWrap_Vector3.html
last_updated: "2026.04.06 오후 02:50"
---

# ViewportPointToRay

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 함수는 카메라에서 뷰포트 포인트를 통해 나가는 레이를 반환합니다. 주어진 위치는 뷰포트 좌표계에서의 위치를 나타내며, 이 좌표계는 화면의 왼쪽 아래 모서리를 (0, 0)으로 하고 오른쪽 위 모서리를 (1, 1)로 설정합니다. 이 함수를 사용할 때는 주의해야 할 점이 있으며, 잘못된 좌표를 입력할 경우 예상치 못한 결과를 초래할 수 있습니다.

## 함수

ViewportPointToRay(pos)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | pos | 뷰포트 내의 위치를 나타내는 정규화된 좌표입니다. (x, y)는 0~1 사이의 값이며, z는 깊이 값으로 무시됩니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Ray](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Ray) | 지정된 뷰포트 좌표를 기준으로 카메라의 시점에서 발사되는 광선 객체입니다. 이 광선은 origin(광선의 시작점)과 direction(광선의 방향) 정보를 포함하며, 주로 충돌 감지(Raycast)나 객체 선택에 사용됩니다. |

## 예제 코드

```lua
local serviceApi = this.serviceApi
local physicsService = serviceApi.physicsService
local camera = someCamera

-- 화면의 중앙(0.5, 0.5)에서 광선을 생성
local ray = camera:ViewportPointToRay(Vector3(0.5, 0.5, 0))

local maxDistance = 10.0
local hit, hitInfo = physicsService:RaycastWithHit(ray, maxDistance)

if hit then
    print("중앙 시야에서 충돌한 오브젝트:", hitInfo.collider.name)
else
    print("중앙 시야에서 충돌 없음")
end
```
