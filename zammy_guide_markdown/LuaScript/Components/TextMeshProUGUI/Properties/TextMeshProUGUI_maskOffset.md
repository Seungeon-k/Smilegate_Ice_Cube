---
title: maskOffset
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_maskOffset
source_path: LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_maskOffset.html
last_updated: "2026.04.06 오후 02:56"
---

# maskOffset

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 프로퍼티는 텍스트의 마스크 오프셋을 정의하는 데 사용됩니다. 마스크 오프셋은 텍스트가 마스크에 의해 어떻게 잘리는지를 결정합니다. 이 값을 조정하여 텍스트의 표시 영역을 변경할 수 있습니다.

사용 시 주의할 점은, 이 프로퍼티가 동기화되지 않으므로 멀티스레드 환경에서의 사용은 권장되지 않습니다. 또한, 마스크 오프셋을 설정할 때는 적절한 [Vector4](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector4) 값을 사용해야 하며, 잘못된 값은 예외를 발생시킬 수 있습니다.

## 프로퍼티 정의

- **이름**: `maskOffset`
- **타입**: [`Vector4`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector4)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local offset = textMeshProUGUI.maskOffset
textMeshProUGUI.maskOffset = newVector4
```

## 참고 사항
