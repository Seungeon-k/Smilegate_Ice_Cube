---
title: pixelRect
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas/Properties/Canvas_pixelRect
source_path: LuaScript/Components/Canvas/Properties/Canvas_pixelRect.html
last_updated: "2026.04.06 오후 02:51"
---

# pixelRect

## 객체

> [Canvas](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas)

## 설명

이 프로퍼티는 캔버스의 렌더링 사각형을 반환합니다. 캔버스의 픽셀 좌표계를 기준으로 하며, UI 요소의 배치 및 크기를 결정하는 데 사용됩니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 사용 시 주의할 점은 캔버스의 크기나 비율이 변경될 경우 이 값도 변경될 수 있다는 점입니다.

## 프로퍼티 정의

- **이름**: `pixelRect`
- **타입**: `Rect`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local rect = canvas.pixelRect
```

## 참고 사항
