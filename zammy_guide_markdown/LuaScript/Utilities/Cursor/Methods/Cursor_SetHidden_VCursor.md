---
title: SetHidden
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Methods/Cursor_SetHidden_VCursor
source_path: LuaScript/Utilities/Cursor/Methods/Cursor_SetHidden_VCursor.html
last_updated: "2026.04.06 오후 03:30"
---

# SetHidden

## 객체

> Cursor

## 설명

SetHidden은 커서를 숨김 상태로 전환합니다.  

연출 구간이나 조작 제한 구간에서 시각 노이즈를 줄이는 용도로 사용합니다.  

다시 표시할 시점을 명확히 정해 SetPointer 또는 Set 호출로 복원하는 흐름을 권장합니다.

## 함수

SetHidden()

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| 없음 | - | 입력 인자 없이 `Hidden` 상태를 현재 컨텍스트 기준으로 설정합니다. 호출 전에 대상 객체 초기화와 권한 상태를 점검해 동기화 오차를 줄이세요. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local inputService = this.serviceApi.inputService
    local cursor = inputService.cursor
    cursor:SetHidden()
end
```
