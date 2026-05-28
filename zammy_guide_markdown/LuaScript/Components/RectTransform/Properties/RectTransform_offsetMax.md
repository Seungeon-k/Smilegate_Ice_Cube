---
title: offsetMax
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform/Properties/RectTransform_offsetMax
source_path: LuaScript/Components/RectTransform/Properties/RectTransform_offsetMax.html
last_updated: "2026.04.06 오후 02:54"
---

# offsetMax

## 객체

> [RectTransform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform)

## 설명

이 프로퍼티는 사각형의 오른쪽 상단 모서리의 오프셋을 오른쪽 상단 앵커에 상대적으로 설정합니다. 이를 통해 UI 요소의 위치를 조정할 수 있습니다.

오프셋 값은 [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2) 형식으로 반환되며, x와 y 좌표를 포함합니다. 이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 현재 오프셋 값을 가져오거나 새로운 값을 설정할 수 있습니다.

값을 설정할 때는 주의가 필요하며, 잘못된 값이 설정될 경우 UI 요소의 위치가 의도치 않게 변경될 수 있습니다.

## 프로퍼티 정의

- **이름**: `offsetMax`
- **타입**: [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local offset = rectTransform.offsetMax
rectTransform.offsetMax = Vector2(100, 200)
```

## 참고 사항

동기화 미지원
