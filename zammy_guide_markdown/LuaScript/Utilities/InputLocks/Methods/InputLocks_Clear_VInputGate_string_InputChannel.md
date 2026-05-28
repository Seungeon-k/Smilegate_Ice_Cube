---
title: Clear
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/InputLocks/Methods/InputLocks_Clear_VInputGate_string_InputChannel
source_path: LuaScript/Utilities/InputLocks/Methods/InputLocks_Clear_VInputGate_string_InputChannel.html
last_updated: "2026.04.06 오후 03:30"
---

# Clear

## 객체

> InputLocks

## 설명

Clear는 tag 입력 차단 상태를 즉시 제거합니다.  

강제 복원 경로가 필요한 예외 처리 블록에서 안전장치로 사용할 수 있습니다.  

여러 시스템이 같은 tag를 사용한다면 영향 범위를 확인한 뒤 호출해야 합니다.

## 함수

Clear(tag, channel)

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
    gate:Clear("shop_ui", InputChannel.Gameplay)
end
```
