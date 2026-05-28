---
title: isBlocked
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/InputLocks/Properties/InputLocks_isBlocked
source_path: LuaScript/Utilities/InputLocks/Properties/InputLocks_isBlocked.html
last_updated: "2026.04.06 오후 03:30"
---

# isBlocked

## 객체

> InputLocks

## 설명

`isBlocked`는 입력 게이트에 하나 이상 차단 레이어가 걸려 있는지를 나타내는 전역 상태 값입니다.  

값이 `true`이면 게임플레이 입력 중 일부 또는 전체가 차단된 상태이므로, 이동/점프/상호작용 처리 전에 먼저 확인해 UI 중복 입력을 막아야 합니다.  

여러 시스템이 동시에 락을 잡을 수 있으므로 `gate:GetCount(tag, channel)`와 함께 사용해 누가 락을 유지 중인지 추적하면 해제 누락을 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: isBlocked
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local gate = this.serviceApi.inputService.gate
    local blocked = gate.isBlocked
    this.scriptObject:Log("global input blocked = " .. tostring(blocked))
end
```
