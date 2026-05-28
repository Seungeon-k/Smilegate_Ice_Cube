---
title: OnChanged
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Events/Cursor_OnChanged
source_path: LuaScript/Utilities/Cursor/Events/Cursor_OnChanged.html
last_updated: "2026.04.06 오후 03:29"
---

# OnChanged

## 객체

> Cursor

## 설명

OnChanged는 커서 잠금/가시성 상태가 바뀔 때 호출됩니다.  

커서 상태 아이콘이나 조작 가이드 텍스트를 실시간 동기화할 때 유용합니다.  

빈번한 변경 구간에서는 핸들러에서 무거운 연산을 피하고 최소 갱신만 수행하는 것이 좋습니다.

## 프로퍼티 정의

- **이름**: `OnChanged`
- **타입**: `VUEventVoid`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| 없음 | - | 이 이벤트는 인자를 전달하지 않습니다. 핸들러 내부에서 `this.serviceApi.inputService.cursor`를 다시 조회해 최신 상태(`isCaptured`, `isVisible`, `isPointer`)를 사용하세요. |

## 사용 예제

```lua
function this.OnStart()
    local cursor = this.serviceApi.inputService.cursor
    cursor.OnChanged:AddListener(this.OnCursorChanged)
end

function this.OnCursorChanged()
    local cursor = this.serviceApi.inputService.cursor
    this.scriptObject:Log(
        "captured=" .. tostring(cursor.isCaptured) ..
        ", visible=" .. tostring(cursor.isVisible)
    )
end

function this.OnDestroy()
    local cursor = this.serviceApi.inputService.cursor
    cursor.OnChanged:RemoveListener(this.OnCursorChanged)
end
```

## 참고 사항

UI 진입/종료 과정에서 커서 상태가 연속 변경되면 `OnChanged`가 짧은 간격으로 여러 번 호출될 수 있습니다.  

핸들러에서는 상태 반영만 수행하고, 무거운 UI 재구성은 별도 지연 처리로 분리하는 구성이 안전합니다.
