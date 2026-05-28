---
title: UpdateFontAsset
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_UpdateFontAsset_UTextMeshProUGUIWrap
source_path: LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_UpdateFontAsset_UTextMeshProUGUIWrap.html
last_updated: "2026.04.06 오후 02:56"
---

# UpdateFontAsset

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 함수는 텍스트 메쉬 프로 UI의 폰트 자산을 업데이트합니다. 이 메서드는 폰트 자산이 변경되었을 때 호출되어야 하며, 이를 통해 UI에서 텍스트가 올바르게 표시되도록 보장합니다. 사용 시 주의할 점은 이 메서드가 호출된 후 UI가 즉시 업데이트되지 않을 수 있으므로, 필요에 따라 추가적인 업데이트 로직을 구현해야 할 수 있습니다.

## 함수

UpdateFontAsset()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
TextMeshProUGUI:UpdateFontAsset()
```
