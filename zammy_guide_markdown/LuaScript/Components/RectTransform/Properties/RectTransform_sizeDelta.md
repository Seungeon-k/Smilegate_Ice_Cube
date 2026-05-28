---
title: sizeDelta
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform/Properties/RectTransform_sizeDelta
source_path: LuaScript/Components/RectTransform/Properties/RectTransform_sizeDelta.html
last_updated: "2026.04.06 오후 02:54"
---

# sizeDelta

## 객체

> [RectTransform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform)

## 설명

이 프로퍼티는 RectTransform의 크기를 앵커 간의 거리와 관련하여 설정하거나 가져옵니다. 크기는 2D 벡터 형태로 표현되며, x와 y 값으로 구성됩니다. 이 값을 조정하면 UI 요소의 크기를 변경할 수 있습니다.

크기를 설정할 때, 앵커의 위치에 따라 크기가 어떻게 변할지 주의해야 합니다. 앵커가 서로 다른 위치에 있을 경우, sizeDelta의 값이 예상과 다르게 나타날 수 있습니다. 또한, 이 프로퍼티는 RectTransform의 크기를 직접적으로 변경하므로, 다른 UI 요소와의 관계를 고려하여 사용해야 합니다.

## 프로퍼티 정의

- **이름**: `sizeDelta`
- **타입**: [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local size = rectTransform.sizeDelta
rectTransform.sizeDelta = Vector2(x, y)
```

## 참고 사항

동기화 미지원
