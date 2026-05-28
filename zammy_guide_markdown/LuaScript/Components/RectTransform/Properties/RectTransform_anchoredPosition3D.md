---
title: anchoredPosition3D
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform/Properties/RectTransform_anchoredPosition3D
source_path: LuaScript/Components/RectTransform/Properties/RectTransform_anchoredPosition3D.html
last_updated: "2026.04.06 오후 02:54"
---

# anchoredPosition3D

## 객체

> [RectTransform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/RectTransform)

## 설명

이 프로퍼티는 RectTransform의 피벗의 3D 위치를 앵커 기준점에 상대적으로 나타냅니다. 이 값을 사용하여 UI 요소의 위치를 조정할 수 있습니다.

이 프로퍼티는 읽기 및 쓰기가 가능하며, [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 타입으로 반환됩니다. 사용 시 주의할 점은, 이 값이 앵커의 위치에 따라 달라질 수 있다는 것입니다. 따라서 앵커의 위치를 변경하면 이 프로퍼티의 값도 변경될 수 있습니다.

## 프로퍼티 정의

- **이름**: `anchoredPosition3D`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local position = rectTransform.anchoredPosition3D
rectTransform.anchoredPosition3D = newPosition
```

## 참고 사항

동기화 미지원
