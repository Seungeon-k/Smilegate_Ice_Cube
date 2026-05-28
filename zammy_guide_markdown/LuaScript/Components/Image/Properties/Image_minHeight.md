---
title: minHeight
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_minHeight
source_path: LuaScript/Components/Image/Properties/Image_minHeight.html
last_updated: "2026.04.06 오후 02:52"
---

# minHeight

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 최소 높이를 반환합니다. 이 값은 이미지의 크기를 조정할 때 유용하게 사용될 수 있습니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 사용자는 이 값을 직접 변경할 수 없으며, 이미지의 속성에 따라 자동으로 결정됩니다.

## 프로퍼티 정의

- **이름**: `minHeight`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local minHeight = image.minHeight
```

## 참고 사항

동기화 미지원
