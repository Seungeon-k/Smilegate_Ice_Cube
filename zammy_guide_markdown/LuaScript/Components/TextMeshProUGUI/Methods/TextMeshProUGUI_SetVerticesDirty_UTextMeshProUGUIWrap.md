---
title: SetVerticesDirty
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetVerticesDirty_UTextMeshProUGUIWrap
source_path: LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetVerticesDirty_UTextMeshProUGUIWrap.html
last_updated: "2026.04.06 오후 02:56"
---

# SetVerticesDirty

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 함수는 텍스트 메쉬의 정점 데이터를 더럽혀서 다음 렌더링 시 업데이트를 강제합니다. 이 메서드는 텍스트의 시각적 변경 사항이 있을 때 호출해야 하며, 이를 통해 텍스트가 올바르게 표시되도록 보장합니다. 사용 시 주의할 점은 이 메서드를 호출한 후에는 반드시 렌더링이 이루어져야 하며, 호출 후 즉시 결과를 확인할 수 없습니다.

## 함수

SetVerticesDirty()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
TextMeshProUGUI:SetVerticesDirty()
```
