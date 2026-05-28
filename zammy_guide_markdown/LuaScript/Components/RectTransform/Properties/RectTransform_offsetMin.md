---
title: offsetMin
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform/Properties/RectTransform_offsetMin
source_path: LuaScript/Components/RectTransform/Properties/RectTransform_offsetMin.html
last_updated: "2026.04.06 오후 02:54"
---

# offsetMin

## 객체

> [RectTransform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform)

## 설명

이 프로퍼티는 사각형의 왼쪽 아래 모서리의 오프셋을 왼쪽 아래 앵커에 대해 설정하거나 가져옵니다. 이를 통해 UI 요소의 위치를 조정할 수 있습니다.

오프셋 값은 [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2) 형식으로, x와 y 좌표를 포함합니다. 이 값을 설정하면 해당 UI 요소의 위치가 변경되며, 앵커의 위치에 따라 상대적으로 조정됩니다.

## 프로퍼티 정의

- **이름**: `offsetMin`
- **타입**: [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local offset = rectTransform.offsetMin
rectTransform.offsetMin = Vector2(10, 20)
```

## 참고 사항

동기화 미지원
