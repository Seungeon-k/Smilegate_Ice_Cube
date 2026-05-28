---
title: canvasRenderer
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_canvasRenderer
source_path: LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_canvasRenderer.html
last_updated: "2026.04.06 오후 02:56"
---

# canvasRenderer

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

`canvasRenderer`는 `TextMeshProUGUI` 객체의 캔버스 렌더러를 반환합니다. 이 프로퍼티는 읽기 전용이며, 캔버스 렌더링을 위한 다양한 설정을 조작할 수 있는 `CanvasRenderer` 객체를 제공합니다. 이 프로퍼티를 통해 텍스트의 렌더링 속성을 조정할 수 있습니다.

이 프로퍼티는 설정할 수 없으므로, 값을 변경하려고 하면 예외가 발생하지 않지만, 의도한 대로 작동하지 않을 수 있습니다. 사용 시 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `canvasRenderer`
- **타입**: `CanvasRenderer`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local canvasRenderer = textMeshProUGUI.canvasRenderer
```

## 참고 사항
