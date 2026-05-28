---
title: nearClipPlane
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Properties/Camera_nearClipPlane
source_path: LuaScript/Components/Camera/Properties/Camera_nearClipPlane.html
last_updated: "2026.04.06 오후 02:51"
---

# nearClipPlane

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 프로퍼티는 카메라의 근접 클리핑 평면까지의 거리를 월드 단위로 설정하거나 가져옵니다. 이 값은 카메라가 렌더링할 수 있는 가장 가까운 거리로, 이 값보다 가까운 물체는 렌더링되지 않습니다.

근접 클리핑 평면의 거리를 적절하게 설정하는 것은 카메라의 시야를 최적화하는 데 중요합니다. 너무 작은 값으로 설정하면, 가까운 물체가 잘리거나 왜곡될 수 있습니다.

예외 케이스로는, 음수 값을 설정할 경우 유효하지 않은 값으로 간주되어 오류가 발생할 수 있습니다. 따라서 항상 0 이상의 값을 설정해야 합니다.

[CamearController](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo) 를 사용 할 경우 해당 내용은 [CamearController](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo)의 설정 내용에 따라 동작 합니다.

## 프로퍼티 정의

- **이름**: `nearClipPlane`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local camera = someCamera

-- 현재 설정된 값 출력
print("현재 nearClipPlane:", camera.nearClipPlane)

-- 클리핑 평면을 0.2로 설정
camera.nearClipPlane = 0.2
print("변경된 nearClipPlane:", camera.nearClipPlane)
```

## 참고 사항

- 너무 작은 nearClipPlane은 깊이 버퍼 정밀도 문제를 유발할 수 있으며,  

이로 인해 표면이 겹치는 오브젝트에서 깜빡임(Z-fighting)이 발생할 수 있습니다.
- 원근 투영을 사용하는 경우, nearClipPlane과 farClipPlane의 비율이 크면  

깊이 정밀도가 떨어지므로 두 값의 비율을 적절히 유지하는 것이 좋습니다.
- 일반적으로 nearClipPlane은 0.1 이상, farClipPlane은 수백 단위의 거리로 설정하는 것이 이상적입니다.
