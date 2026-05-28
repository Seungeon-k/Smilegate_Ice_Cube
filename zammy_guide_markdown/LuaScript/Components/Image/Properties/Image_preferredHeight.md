---
title: preferredHeight
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_preferredHeight
source_path: LuaScript/Components/Image/Properties/Image_preferredHeight.html
last_updated: "2026.04.06 오후 02:52"
---

# preferredHeight

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 선호 높이를 반환합니다. 이 값은 이미지가 표시될 때의 높이를 결정하는 데 사용됩니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 사용 시 주의할 점은 이 값이 이미지의 실제 높이와 다를 수 있다는 것입니다. 예를 들어, 이미지의 크기가 조정되거나 부모 컨테이너의 크기에 따라 달라질 수 있습니다.

## 프로퍼티 정의

- **이름**: `preferredHeight`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local height = image.preferredHeight
```

## 참고 사항

동기화 미지원
