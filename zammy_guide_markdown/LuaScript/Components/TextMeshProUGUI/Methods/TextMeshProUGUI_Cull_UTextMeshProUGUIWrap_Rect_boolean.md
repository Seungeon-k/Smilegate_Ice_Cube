---
title: Cull
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_Cull_UTextMeshProUGUIWrap_Rect_boolean
source_path: LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_Cull_UTextMeshProUGUIWrap_Rect_boolean.html
last_updated: "2026.04.06 오후 02:56"
---

# Cull

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 함수는 주어진 클립 영역에 따라 텍스트의 가시성을 조정합니다. `clipRect`는 텍스트가 표시될 영역을 정의하며, `validRect`는 이 영역이 유효한지를 나타냅니다. 이 함수를 호출하면 텍스트의 렌더링이 해당 클립 영역에 맞춰 조정됩니다.

## 함수

Cull(clipRect, validRect)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `Rect` | `clipRect` | 텍스트가 표시될 영역 |
| `boolean` | `validRect` | 클립 영역의 유효성 여부 |

### 반환값

없음

## 예제 코드

```lua
TextMeshProUGUI:Cull(clipRect, validRect)
```
