---
title: SetPointer
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Methods/Cursor_SetPointer
source_path: LuaScript/Utilities/Cursor/Methods/Cursor_SetPointer.html
last_updated: "2026.04.06 오후 03:30"
---

# SetPointer

## 객체

> Cursor

## 설명

SetPointer는 커서를 포인터 모드로 전환하며 제한 여부와 표시 여부를 함께 제어합니다.  

UI 조작 구간에서 this.serviceApi.inputService.cursor 경로로 호출해 커서 정책을 일관되게 관리합니다.  

화면 종료 시 캡처/숨김 모드로 되돌릴 복원 경로를 함께 설계하는 것이 안전합니다.  

`confined`, `visible`는 선택 매개변수들입니다. 생략하면 `SetPointer()` 형태로 호출할 수 있습니다.

## 함수

SetPointer()  
  

SetPointer(confined)  
  

SetPointer(confined, visible)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `bool` | `confined` | true/false 플래그 값입니다. 생략하면 해당 인자를 받지 않는 호출 형태가 사용됩니다. |
| `bool` | `visible` | true/false 플래그 값입니다. 생략하면 해당 인자를 받지 않는 호출 형태가 사용됩니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| `void` | 모든 호출 조합에서 값을 반환하지 않습니다. |

## 예제 코드

```lua
function this.OnStart()
    local inputService = this.serviceApi.inputService
    local cursor = inputService.cursor
    cursor:SetPointer(true, true)
end
```
