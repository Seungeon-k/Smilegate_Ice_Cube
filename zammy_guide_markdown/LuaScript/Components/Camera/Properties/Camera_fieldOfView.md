---
title: fieldOfView
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Properties/Camera_fieldOfView
source_path: LuaScript/Components/Camera/Properties/Camera_fieldOfView.html
last_updated: "2026.04.06 오후 02:51"
---

# fieldOfView

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 프로퍼티는 카메라의 수직 시야각을 도 단위로 설정하거나 가져옵니다. 시야각은 카메라가 포착할 수 있는 수직 범위를 정의하며, 값이 클수록 더 넓은 시야를 제공합니다. 일반적으로 시야각은 1도에서 179도 사이의 값을 가집니다.

유의사항으로는, 시야각이 너무 크면 왜곡이 발생할 수 있으며, 너무 작으면 시야가 제한될 수 있습니다. 적절한 시야각을 설정하는 것이 중요합니다.

[CamearController](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo) 를 사용 할 경우 해당 내용은 [CamearController](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo)의 설정 내용에 따라 동작 합니다.

## 프로퍼티 정의

- **이름**: `fieldOfView`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local camera = someCamera

-- 현재 시야각 출력
print("현재 시야각:", camera.fieldOfView)

-- 시야각을 70도로 설정 (넓은 시야)
camera.fieldOfView = 70
print("변경된 시야각:", camera.fieldOfView)

-- 시야각을 40도로 줄이면 망원 효과처럼 보임
camera.fieldOfView = 40
print("좁은 시야로 변경됨:", camera.fieldOfView)
```
