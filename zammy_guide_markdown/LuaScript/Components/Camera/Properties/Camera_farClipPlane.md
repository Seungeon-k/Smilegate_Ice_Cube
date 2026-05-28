---
title: farClipPlane
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Properties/Camera_farClipPlane
source_path: LuaScript/Components/Camera/Properties/Camera_farClipPlane.html
last_updated: "2026.04.06 오후 02:50"
---

# farClipPlane

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 프로퍼티는 카메라의 원거리 클리핑 평면까지의 거리를 월드 단위로 설정하거나 가져옵니다. 이 값은 카메라가 렌더링할 수 있는 최대 거리로, 이 값보다 먼 물체는 렌더링되지 않습니다.

값을 설정할 때는 적절한 범위 내에서 설정해야 하며, 너무 큰 값은 성능에 영향을 줄 수 있습니다.

[CamearController](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo) 를 사용 할 경우 해당 내용은 [CamearController](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo)의 설정 내용에 따라 동작 합니다.

## 프로퍼티 정의

- **이름**: `farClipPlane`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local camera = someCamera

-- 현재 설정된 farClipPlane 값 출력
print("현재 farClipPlane:", camera.farClipPlane)

-- 원거리 클리핑 평면을 500 단위로 설정
camera.farClipPlane = 500.0

-- 변경된 값 확인
print("변경된 farClipPlane:", camera.farClipPlane)
```

## 참고 사항

- farClipPlane 값이 커질수록 렌더링할 공간이 넓어지므로, 렌더링 부하와 성능 저하가 발생할 수 있습니다.
