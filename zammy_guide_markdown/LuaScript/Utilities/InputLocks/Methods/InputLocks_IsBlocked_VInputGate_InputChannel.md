---
title: IsBlocked
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/InputLocks/Methods/InputLocks_IsBlocked_VInputGate_InputChannel
source_path: LuaScript/Utilities/InputLocks/Methods/InputLocks_IsBlocked_VInputGate_InputChannel.html
last_updated: "2026.04.06 오후 03:30"
---

# IsBlocked

## 객체

> InputLocks

## 설명

IsBlocked는 지정 channel의 입력 차단 여부를 반환합니다.  

화면 전환 시점의 조작 가능 여부를 즉시 분기할 때 사용하기 좋습니다.  

시스템 차단과 태그 차단 결과를 모두 반영하므로 실제 입력 가능 상태 판단에 유용합니다.

## 함수

IsBlocked(channel)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| InputChannel | channel | `channel`는 [`InputChannel`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/InputChannel) 선택값입니다. 허용된 상수만 전달하고 기본 분기를 함께 두어 예외 케이스를 처리하세요. |

### 반환값

`IsBlocked`의 반환값은 현재 조건에 대한 참/거짓 판정입니다. `true`/`false` 경로를 분리해 후속 처리(재시도/대체 흐름)를 명시하세요.

## 예제 코드

```lua
function this.OnStart()
    local gate = this.serviceApi.inputService.gate
    local blocked = gate:IsBlocked(InputChannel.Gameplay)
    this.scriptObject:Log("게임플레이 입력 차단 여부: " .. tostring(blocked))
end
```
