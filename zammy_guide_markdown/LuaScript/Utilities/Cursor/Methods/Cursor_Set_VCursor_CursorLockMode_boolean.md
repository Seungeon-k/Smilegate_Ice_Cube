---
title: Set
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Methods/Cursor_Set_VCursor_CursorLockMode_boolean
source_path: LuaScript/Utilities/Cursor/Methods/Cursor_Set_VCursor_CursorLockMode_boolean.html
last_updated: "2026.04.06 오후 03:30"
---

# Set

## 객체

> Cursor

## 설명

`Set`는 `lockState와 visible` 값을 적용해 상태를 갱신합니다. 설정 직후 연관 시스템의 반영 순서를 맞춰 호출해야 예기치 않은 동기화 오차를 줄일 수 있습니다.  

`Set`는 호출 프레임에 바로 반영되므로, 같은 프레임에서 중복 호출되지 않게 실행 순서를 고정하세요.  

`Set`는 `대상 값` 값을 덮어쓰므로, 동시에 여러 스크립트가 호출하지 않도록 상태 갱신 책임을 단일화하세요.

## 함수

Set(lockState, visible)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| CursorLockMode | lockState | `lockState`는 [`CursorLockMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/CursorLockMode) 선택값입니다. 허용된 상수만 전달하고 기본 분기를 함께 두어 예외 케이스를 처리하세요. |
| boolean | visible | visible는 true/false 상태 제어 플래그입니다. 기본 동작과 반대 동작을 전환할 때 사용합니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local inputService = this.serviceApi.inputService
    local cursor = inputService.cursor
    cursor:Set(CursorLockMode.None, true)
end
```
