---
title: scaleFactor
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas/Properties/Canvas_scaleFactor
source_path: LuaScript/Components/Canvas/Properties/Canvas_scaleFactor.html
last_updated: "2026.04.06 오후 02:51"
---

# scaleFactor

## 객체

> [Canvas](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas)

## 설명

이 프로퍼티는 전체 캔버스를 스케일링하여 화면에 맞게 조정하는 데 사용됩니다. 이 기능은 renderMode가 Screen Space일 때만 적용됩니다. 스케일 팩터를 조정하면 UI 요소의 크기가 변경되며, 이를 통해 다양한 해상도에서 일관된 사용자 경험을 제공할 수 있습니다.

스케일 팩터는 실수형 값으로 설정되며, 1.0은 기본 크기를 의미합니다. 이 값을 조정하여 캔버스의 크기를 늘리거나 줄일 수 있습니다. 그러나 이 프로퍼티는 동기화를 지원하지 않으므로 멀티스레드 환경에서 사용할 때 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `scaleFactor`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
canvas.scaleFactor
```

## 참고 사항
