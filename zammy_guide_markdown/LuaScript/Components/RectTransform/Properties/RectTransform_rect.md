---
title: rect
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform/Properties/RectTransform_rect
source_path: LuaScript/Components/RectTransform/Properties/RectTransform_rect.html
last_updated: "2026.04.06 오후 02:54"
---

# rect

## 객체

> [RectTransform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform)

## 설명

이 프로퍼티는 Transform의 로컬 공간에서 계산된 사각형을 반환합니다. 이 값은 Rect 구조체로 표현되며, Transform의 크기와 위치에 따라 동적으로 결정됩니다. 이 프로퍼티는 읽기 전용이며, 직접적으로 값을 설정할 수 없습니다. 사용 시 주의해야 할 점은, 이 값이 Transform의 상태에 따라 변할 수 있으므로, 필요할 때마다 값을 확인해야 한다는 것입니다.

## 프로퍼티 정의

- **이름**: `rect`
- **타입**: `Rect`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local rect = rectTransform.rect
```

## 참고 사항
