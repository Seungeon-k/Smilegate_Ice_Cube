---
title: pixelsPerUnit
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_pixelsPerUnit
source_path: LuaScript/Components/Image/Properties/Image_pixelsPerUnit.html
last_updated: "2026.04.06 오후 02:52"
---

# pixelsPerUnit

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

`pixelsPerUnit`은 이미지의 픽셀 밀도를 나타내는 프로퍼티입니다. 이 값은 이미지의 해상도를 조정하는 데 사용되며, 주로 UI 요소의 크기를 결정하는 데 중요한 역할을 합니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다.

이 프로퍼티를 사용할 때는 이미지의 해상도에 따라 적절한 값을 확인해야 합니다. 잘못된 값이 사용될 경우, 이미지가 왜곡되거나 예상치 못한 결과를 초래할 수 있습니다.

## 프로퍼티 정의

- **이름**: `pixelsPerUnit`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local pixelsPerUnit = image.pixelsPerUnit
```

## 참고 사항

동기화 미지원
