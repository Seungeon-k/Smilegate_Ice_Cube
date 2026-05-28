---
title: materialForRendering
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_materialForRendering
source_path: LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_materialForRendering.html
last_updated: "2026.04.06 오후 02:56"
---

# materialForRendering

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 프로퍼티는 텍스트 렌더링에 사용되는 머티리얼을 반환합니다. 이 머티리얼은 텍스트의 시각적 표현을 결정하는 중요한 요소입니다. 이 프로퍼티는 읽기 전용이며, 직접적으로 값을 설정할 수 없습니다.

머티리얼을 변경하려면 다른 방법을 사용해야 하며, 이 프로퍼티를 통해 현재 사용 중인 머티리얼을 확인할 수 있습니다.

## 프로퍼티 정의

- **이름**: `materialForRendering`
- **타입**: `Material`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local material = textMeshProUGUI.materialForRendering
```

## 참고 사항
