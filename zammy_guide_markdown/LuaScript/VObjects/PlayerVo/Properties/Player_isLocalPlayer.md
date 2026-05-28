---
title: isLocalPlayer
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Properties/Player_isLocalPlayer
source_path: LuaScript/VObjects/PlayerVo/Properties/Player_isLocalPlayer.html
last_updated: "2026.04.06 오후 03:36"
---

# isLocalPlayer

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`isLocalPlayer`는 해당 `Player` 객체가 현재 클라이언트를 대표하는 로컬 플레이어인지 나타냅니다.  

UI 입력 처리, 카메라 추적, 로컬 전용 연출은 이 값이 `true`인 객체에서만 실행해야 원격 플레이어에 대한 중복 처리를 막을 수 있습니다.  

플레이어 목록 순회 시 항상 이 값을 먼저 검사한 뒤 로컬 전용 로직을 분기하면 멀티플레이 동기화 오류를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: isLocalPlayer
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local player = this.serviceApi.playerService.localPlayer
    if player ~= nil and player.isLocalPlayer then
        this.scriptObject:Log("로컬 플레이어 컨텍스트입니다.")
    end
end
```
