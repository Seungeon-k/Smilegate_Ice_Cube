---
title: mesh
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_mesh
source_path: LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_mesh.html
last_updated: "2026.04.06 오후 02:56"
---

# mesh

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 프로퍼티는 `TextMeshProUGUI` 객체의 메쉬를 반환합니다. 메쉬는 텍스트 렌더링에 사용되는 3D 형상을 나타내며, 이 프로퍼티를 통해 현재 텍스트의 메쉬 정보를 얻을 수 있습니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 메쉬를 직접 수정하거나 재설정할 수는 없습니다.

예외 케이스로는, `TextMeshProUGUI` 객체가 초기화되지 않았거나, 텍스트가 비어 있는 경우 메쉬가 유효하지 않을 수 있습니다. 이러한 경우에는 반환된 메쉬가 `nil`일 수 있습니다.

## 프로퍼티 정의

- **이름**: `mesh`
- **타입**: `Mesh`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local mesh = textMeshProUGUI.mesh
```

## 참고 사항
