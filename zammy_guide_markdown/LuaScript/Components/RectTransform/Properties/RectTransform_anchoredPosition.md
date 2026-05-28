---
title: anchoredPosition
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform/Properties/RectTransform_anchoredPosition
source_path: LuaScript/Components/RectTransform/Properties/RectTransform_anchoredPosition.html
last_updated: "2026.04.06 오후 02:54"
---

# anchoredPosition

## 객체

> [RectTransform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform)

## 설명

이 프로퍼티는 RectTransform의 피벗 위치를 앵커 기준점에 대해 상대적으로 설정합니다. 이를 통해 UI 요소의 위치를 조정할 수 있습니다.

이 프로퍼티는 읽기 및 쓰기가 가능하며, [Vector2](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2) 타입의 값을 반환합니다. 사용 시 주의할 점은 앵커의 위치에 따라 피벗 위치가 달라질 수 있다는 것입니다.

## 프로퍼티 정의

- **이름**: `anchoredPosition`
- **타입**: [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local position = rectTransform.anchoredPosition
rectTransform.anchoredPosition = Vector2(x, y)
```

## 참고 사항

동기화 미지원
