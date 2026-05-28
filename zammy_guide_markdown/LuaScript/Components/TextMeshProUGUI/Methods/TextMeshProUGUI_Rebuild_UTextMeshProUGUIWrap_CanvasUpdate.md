---
title: Rebuild
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_Rebuild_UTextMeshProUGUIWrap_CanvasUpdate
source_path: LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_Rebuild_UTextMeshProUGUIWrap_CanvasUpdate.html
last_updated: "2026.04.06 오후 02:56"
---

# Rebuild

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 함수는 텍스트 메쉬 프로 UI 요소의 레이아웃을 재구성합니다. 주어진 업데이트 단계에 따라 텍스트의 시각적 표현을 조정합니다. 이 메서드는 텍스트가 변경되었거나 레이아웃이 필요할 때 호출해야 합니다.

예외 케이스는 없으며, 적절한 업데이트 단계를 선택하여 호출해야 합니다.

## 함수

Rebuild(update)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [CanvasUpdate](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/CanvasUpdate) | `update` | 업데이트 단계 |

### 반환값

없음

## 예제 코드

```lua
TextMeshProUGUI:Rebuild(update)
```
