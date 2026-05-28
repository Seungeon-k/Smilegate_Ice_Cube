---
title: Block
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/InputLocks/Methods/InputLocks_Block_VInputGate_string_InputChannel
source_path: LuaScript/Utilities/InputLocks/Methods/InputLocks_Block_VInputGate_string_InputChannel.html
last_updated: "2026.04.06 오후 03:30"
---

# Block

## 객체

> InputLocks

## 설명

Block은 tag와 channel 기준으로 입력 차단 카운트를 증가시킵니다.  

같은 tag를 여러 시스템이 공유하는 경우 누적 카운트로 충돌을 방지할 수 있습니다.  

UI 진입 시 Block, 종료 시 Unblock을 짝으로 관리해 입력 복원 누락을 막아야 합니다.

## 함수

Block(tag, channel)

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
    gate:Block("shop_ui", InputChannel.Gameplay)
end
```
