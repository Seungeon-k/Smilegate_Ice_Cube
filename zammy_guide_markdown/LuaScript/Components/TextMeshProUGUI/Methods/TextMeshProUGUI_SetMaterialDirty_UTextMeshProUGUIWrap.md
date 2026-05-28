---
title: SetMaterialDirty
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetMaterialDirty_UTextMeshProUGUIWrap
source_path: LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetMaterialDirty_UTextMeshProUGUIWrap.html
last_updated: "2026.04.06 오후 02:56"
---

# SetMaterialDirty

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 함수는 텍스트 메쉬 프로의 재질을 변경할 필요가 있을 때 호출합니다. 이 메서드를 호출하면 해당 텍스트 메쉬 프로의 재질이 더럽혀져서 다음 렌더링 시 재질이 업데이트됩니다. 이 함수는 주로 텍스트의 스타일이나 색상이 변경되었을 때 사용됩니다. 호출 후에는 반드시 렌더링이 이루어져야 변경 사항이 반영됩니다.

## 함수

SetMaterialDirty()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
TextMeshProUGUI:SetMaterialDirty()
```
