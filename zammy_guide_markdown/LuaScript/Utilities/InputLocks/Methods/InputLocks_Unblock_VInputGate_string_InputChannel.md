---
title: Unblock
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/InputLocks/Methods/InputLocks_Unblock_VInputGate_string_InputChannel
source_path: LuaScript/Utilities/InputLocks/Methods/InputLocks_Unblock_VInputGate_string_InputChannel.html
last_updated: "2026.04.06 오후 03:30"
---

# Unblock

## 객체

> InputLocks

## 설명

Unblock은 tag와 channel 기준 입력 차단 카운트를 감소시킵니다.  

카운트가 0이 되면 차단이 해제되므로 Block 호출 수와 균형을 맞춰 사용해야 합니다.  

종료 루틴에서 누락 없이 호출해 장시간 세션의 입력 불능 상태를 예방해야 합니다.

## 함수

Unblock(tag, channel)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | tag | tag는 창작자가 자유롭게 정하는 문자열 키입니다. 별도 예약 규칙은 없으며 입력 잠금/해제 호출에서 같은 값을 일관되게 사용하면 됩니다. |
| InputChannel | channel | `channel`는 [`InputChannel`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/InputChannel) 선택값입니다. 허용된 상수만 전달하고 기본 분기를 함께 두어 예외 케이스를 처리하세요. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStop()
    local gate = this.serviceApi.inputService.gate
    gate:Unblock("shop_ui", InputChannel.Gameplay)
end
```
