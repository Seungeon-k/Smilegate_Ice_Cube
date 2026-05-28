---
title: pivot
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform/Properties/RectTransform_pivot
source_path: LuaScript/Components/RectTransform/Properties/RectTransform_pivot.html
last_updated: "2026.04.06 오후 02:54"
---

# pivot

## 객체

> [RectTransform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform)

## 설명

이 프로퍼티는 RectTransform의 회전 중심이 되는 정규화된 위치를 나타냅니다. 이 값은 0에서 1 사이의 범위를 가지며, RectTransform의 크기에 따라 상대적인 위치를 정의합니다.

값을 설정할 때는 주의가 필요하며, 잘못된 값은 예상치 못한 동작을 초래할 수 있습니다. 예를 들어, (0.5, 0.5)로 설정하면 RectTransform의 중앙에서 회전하게 됩니다.

## 프로퍼티 정의

- **이름**: `pivot`
- **타입**: [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local pivot = rectTransform.pivot
rectTransform.pivot = Vector2(0.5, 0.5)
```

## 참고 사항

동기화 미지원
