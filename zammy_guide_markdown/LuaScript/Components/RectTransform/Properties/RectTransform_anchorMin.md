---
title: anchorMin
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform/Properties/RectTransform_anchorMin
source_path: LuaScript/Components/RectTransform/Properties/RectTransform_anchorMin.html
last_updated: "2026.04.06 오후 02:54"
---

# anchorMin

## 객체

> [RectTransform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform)

## 설명

이 프로퍼티는 부모 RectTransform에서 왼쪽 아래 모서리가 고정되는 정규화된 위치를 나타냅니다. 이 값은 0에서 1 사이의 범위를 가지며, 0은 부모 RectTransform의 왼쪽 아래 모서리를 의미하고, 1은 오른쪽 위 모서리를 의미합니다.

이 프로퍼티를 설정하면 RectTransform의 앵커가 변경되며, 이는 UI 요소의 배치에 영향을 미칠 수 있습니다. 따라서 UI 레이아웃을 조정할 때 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `anchorMin`
- **타입**: [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local anchorMin = rectTransform.anchorMin
rectTransform.anchorMin = Vector2(0.5, 0.5)
```

## 참고 사항

동기화 미지원
