---
title: pixelsPerUnitMultiplier
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_pixelsPerUnitMultiplier
source_path: LuaScript/Components/Image/Properties/Image_pixelsPerUnitMultiplier.html
last_updated: "2026.04.06 오후 02:52"
---

# pixelsPerUnitMultiplier

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 픽셀 단위 배율을 설정하거나 가져오는 데 사용됩니다. 픽셀 단위 배율은 이미지가 화면에 표시될 때의 크기를 결정합니다. 이 값을 조정하면 이미지의 해상도와 크기를 조절할 수 있습니다.

값을 설정할 때는 적절한 범위 내에서 설정해야 하며, 잘못된 값은 예외를 발생시킬 수 있습니다. 이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 필요에 따라 동적으로 값을 변경할 수 있습니다.

## 프로퍼티 정의

- **이름**: `pixelsPerUnitMultiplier`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local multiplier = image.pixelsPerUnitMultiplier
image.pixelsPerUnitMultiplier
```

## 참고 사항

동기화 미지원
