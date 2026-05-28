---
title: UpdateVertexData
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_UpdateVertexData
source_path: LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_UpdateVertexData.html
last_updated: "2026.04.06 오후 02:56"
---

# UpdateVertexData

## 객체

> [TextMeshProUGUI](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshProUGUI)

## 설명

이 함수는 텍스트 메쉬 프로의 정점 데이터를 업데이트합니다. 주로 텍스트의 시각적 표현을 갱신할 때 사용됩니다. 이 함수는 호출 후 즉시 변경 사항을 반영하므로, 텍스트가 변경된 후에 호출하는 것이 좋습니다. 예외 케이스는 없으며, 이 함수는 항상 정상적으로 실행됩니다.

이 함수는 텍스트 메쉬 프로의 정점 데이터를 업데이트하는 데 사용됩니다. `flags` 매개변수를 통해 업데이트할 데이터의 종류를 지정할 수 있습니다. 이 함수는 텍스트의 시각적 표현을 변경할 때 유용합니다.

업데이트할 데이터의 종류에 따라 성능에 영향을 줄 수 있으므로, 필요한 데이터만 업데이트하는 것이 좋습니다.

## 함수

UpdateVertexData()  
  

UpdateVertexData(flags)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [TMP_VertexDataUpdateFlags](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/TMP_VertexDataUpdateFlags) | `flags` | 업데이트할 데이터의 종류 |

### 반환값

없음

## 예제 코드

```lua
TextMeshProUGUI:UpdateVertexData(flags)
```
