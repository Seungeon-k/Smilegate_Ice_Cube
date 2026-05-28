---
title: preferredWidth
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_preferredWidth
source_path: LuaScript/Components/Image/Properties/Image_preferredWidth.html
last_updated: "2026.04.06 오후 02:52"
---

# preferredWidth

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 선호 너비를 반환합니다. 이 값은 이미지가 표시될 때의 너비를 결정하는 데 사용됩니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 사용 시 주의할 점은 이 값이 이미지의 실제 너비와 다를 수 있다는 것입니다. 예를 들어, 이미지가 특정 비율로 조정되거나 클리핑될 경우, 반환되는 선호 너비는 실제로 표시되는 너비와 다를 수 있습니다.

## 프로퍼티 정의

- **이름**: `preferredWidth`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local width = image.preferredWidth
```

## 참고 사항

동기화 미지원
