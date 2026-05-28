---
title: SetLayoutDirty
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetLayoutDirty_UTextMeshProUGUIWrap
source_path: LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetLayoutDirty_UTextMeshProUGUIWrap.html
last_updated: "2026.04.06 오후 02:56"
---

# SetLayoutDirty

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 함수는 텍스트 레이아웃을 더럽혀서 다음 렌더링 시에 레이아웃을 업데이트하도록 합니다. 이 메서드는 텍스트가 변경되었거나 레이아웃이 변경된 경우에 호출해야 합니다. 호출 후에는 레이아웃이 즉시 업데이트되지 않으며, 다음 프레임에서 업데이트됩니다. 이 메서드는 주로 UI 요소의 레이아웃을 동적으로 변경할 때 유용합니다.

## 함수

SetLayoutDirty()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
TextMeshProUGUI:SetLayoutDirty()
```
