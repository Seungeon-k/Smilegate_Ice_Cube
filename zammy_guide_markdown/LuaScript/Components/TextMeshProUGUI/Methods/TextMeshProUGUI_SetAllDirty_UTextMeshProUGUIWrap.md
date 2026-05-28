---
title: SetAllDirty
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetAllDirty_UTextMeshProUGUIWrap
source_path: LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetAllDirty_UTextMeshProUGUIWrap.html
last_updated: "2026.04.06 오후 02:56"
---

# SetAllDirty

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 함수는 TextMeshProUGUI 객체의 모든 텍스트를 더럽혀서 업데이트가 필요함을 표시합니다. 이 메서드를 호출하면 텍스트가 다음 렌더링 주기에서 다시 그려지게 됩니다. 사용 시 주의할 점은 이 메서드가 호출된 후 텍스트가 즉시 업데이트되지 않으며, 다음 렌더링 주기에서 반영된다는 점입니다.

## 함수

SetAllDirty()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
TextMeshProUGUI:SetAllDirty()
```
