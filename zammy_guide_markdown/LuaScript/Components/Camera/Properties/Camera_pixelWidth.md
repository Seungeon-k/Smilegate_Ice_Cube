---
title: pixelWidth
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Properties/Camera_pixelWidth
source_path: LuaScript/Components/Camera/Properties/Camera_pixelWidth.html
last_updated: "2026.04.06 오후 02:51"
---

# pixelWidth

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

이 프로퍼티는 카메라의 너비를 픽셀 단위로 반환합니다. 동적 해상도 스케일링을 고려하지 않은 값입니다. 이 값은 읽기 전용이며, 설정할 수 없습니다. 카메라의 해상도에 따라 이 값은 달라질 수 있습니다.

## 프로퍼티 정의

- **이름**: `pixelWidth`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local camera = someCamera

-- 현재 카메라의 해상도 출력
print("카메라 해상도:", camera.pixelWidth, "x", camera.pixelHeight)

-- 화면 비율 계산 (가로 / 세로)
local aspect = camera.pixelWidth / camera.pixelHeight
print(string.format("현재 화면 비율(Aspect Ratio): %.2f", aspect))

-- 화면 중앙 좌표 계산
local screenCenterX = camera.pixelWidth * 0.5
local screenCenterY = camera.pixelHeight * 0.5
print(string.format("화면 중앙 좌표: (%.0f, %.0f)", screenCenterX, screenCenterY))
```
