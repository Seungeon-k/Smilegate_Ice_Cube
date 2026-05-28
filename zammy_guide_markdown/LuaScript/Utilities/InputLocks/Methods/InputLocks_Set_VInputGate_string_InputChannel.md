---
title: Set
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/InputLocks/Methods/InputLocks_Set_VInputGate_string_InputChannel
source_path: LuaScript/Utilities/InputLocks/Methods/InputLocks_Set_VInputGate_string_InputChannel.html
last_updated: "2026.04.06 오후 03:30"
---

# Set

## 객체

> InputLocks

## 설명

Set은 tag 입력 차단 상태를 즉시 활성화합니다.  

중복 호출 시 카운트를 늘리지 않고 존재만 보장하므로 초기화 루틴에 적합합니다.  

해제는 Clear 또는 Unblock으로 통일해 팀 규칙을 유지하는 것이 좋습니다.

## 함수

Set(tag, channel)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | tag | tag는 창작자가 자유롭게 정하는 문자열 키입니다. 별도 예약 규칙은 없으며 입력 잠금/해제 호출에서 같은 값을 일관되게 사용하면 됩니다. |
| InputChannel | channel | `channel`는 [`InputChannel`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/InputChannel) 선택값입니다. 허용된 상수만 전달하고 기본 분기를 함께 두어 예외 케이스를 처리하세요. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local gate = this.serviceApi.inputService.gate
    gate:Set("shop_ui", InputChannel.Gameplay)
end
```
