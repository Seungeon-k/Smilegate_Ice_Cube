---
title: preserveAspect
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_preserveAspect
source_path: LuaScript/Components/Image/Properties/Image_preserveAspect.html
last_updated: "2026.04.06 오후 02:52"
---

# preserveAspect

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 비율을 유지할지 여부를 설정합니다. 비율을 유지하면 이미지가 왜곡되지 않고 원본 비율을 유지하면서 크기가 조정됩니다. 이 설정은 UI 요소에서 이미지의 표시 방식에 영향을 미치므로, 적절한 값으로 설정하는 것이 중요합니다.

예를 들어, 비율을 유지하지 않으면 이미지가 늘어나거나 줄어들 수 있습니다. 이 프로퍼티는 Boolean 타입으로, true로 설정하면 비율을 유지하고, false로 설정하면 비율을 무시합니다.

## 프로퍼티 정의

- **이름**: `preserveAspect`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
image.preserveAspect
```

## 참고 사항

동기화 미지원
