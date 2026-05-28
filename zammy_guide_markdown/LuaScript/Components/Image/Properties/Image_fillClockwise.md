---
title: fillClockwise
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_fillClockwise
source_path: LuaScript/Components/Image/Properties/Image_fillClockwise.html
last_updated: "2026.04.06 오후 02:52"
---

# fillClockwise

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 채우기 방향이 시계 방향인지 여부를 나타냅니다. 기본적으로 false로 설정되어 있으며, true로 설정하면 이미지가 시계 방향으로 채워집니다. 이 프로퍼티를 사용하여 UI 요소의 시각적 표현을 조정할 수 있습니다.

설정 시 유의사항으로, 이 프로퍼티는 이미지의 시각적 표현에 직접적인 영향을 미치므로, 다른 관련 프로퍼티와 함께 사용될 때 주의가 필요합니다. 예를 들어, fillAmount 프로퍼티와 함께 사용하여 채우기 효과를 조정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `fillClockwise`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
image.fillClockwise = true
local isClockwise = image.fillClockwise
```

## 참고 사항

동기화 미지원
