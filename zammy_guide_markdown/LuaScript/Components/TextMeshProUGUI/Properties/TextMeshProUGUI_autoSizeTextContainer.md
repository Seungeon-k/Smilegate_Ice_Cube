---
title: autoSizeTextContainer
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_autoSizeTextContainer
source_path: LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_autoSizeTextContainer.html
last_updated: "2026.04.06 오후 02:56"
---

# autoSizeTextContainer

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 프로퍼티는 텍스트의 크기에 따라 자동으로 텍스트 컨테이너의 크기를 조정할지를 결정합니다. 이 값을 `true`로 설정하면 텍스트의 크기에 맞춰 컨테이너가 자동으로 조정됩니다. 반대로 `false`로 설정하면 컨테이너의 크기가 고정됩니다.

사용 시 주의할 점은, 이 프로퍼티가 `true`로 설정된 경우 텍스트의 내용이 변경될 때마다 컨테이너의 크기가 조정되므로 성능에 영향을 줄 수 있습니다. 따라서 성능이 중요한 경우에는 적절히 사용해야 합니다.

## 프로퍼티 정의

- **이름**: `autoSizeTextContainer`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local autoSize = textMeshProUGUI.autoSizeTextContainer
textMeshProUGUI.autoSizeTextContainer = true
```

## 참고 사항
