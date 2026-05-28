---
title: GetCount
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/InputLocks/Methods/InputLocks_GetCount_VInputGate_string_InputChannel
source_path: LuaScript/Utilities/InputLocks/Methods/InputLocks_GetCount_VInputGate_string_InputChannel.html
last_updated: "2026.04.06 오후 03:30"
---

# GetCount

## 객체

> InputLocks

## 설명

GetCount는 tag와 channel에 걸린 차단 카운트를 반환합니다.  

입력 잠금 상태를 디버깅하거나 운영 로그로 추적할 때 직접 활용할 수 있습니다.  

0보다 큰 값이면 해당 태그 차단이 활성 상태임을 의미합니다.

## 함수

GetCount(tag, channel)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | tag | tag는 창작자가 자유롭게 정하는 문자열 키입니다. 별도 예약 규칙은 없으며 입력 잠금/해제 호출에서 같은 값을 일관되게 사용하면 됩니다. |
| InputChannel | channel | `channel`는 [`InputChannel`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/InputChannel) 선택값입니다. 허용된 상수만 전달하고 기본 분기를 함께 두어 예외 케이스를 처리하세요. |

### 반환값

`GetCount` 호출 시점의 `number` 데이터를 반환합니다. 반환값이 nil/빈 값일 수 있으므로 검증 후 후속 로직으로 전달하세요.

## 예제 코드

```lua
function this.OnStart()
    local gate = this.serviceApi.inputService.gate
    local count = gate:GetCount("shop_ui", InputChannel.Gameplay)
    this.scriptObject:Log("shop_ui lock count: " .. tostring(count))
end
```
