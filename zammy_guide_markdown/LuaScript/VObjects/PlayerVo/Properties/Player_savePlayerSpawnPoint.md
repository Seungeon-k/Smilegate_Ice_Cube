---
title: savePlayerSpawnPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Properties/Player_savePlayerSpawnPoint
source_path: LuaScript/VObjects/PlayerVo/Properties/Player_savePlayerSpawnPoint.html
last_updated: "2026.04.06 오후 03:36"
---

# savePlayerSpawnPoint

## 객체

> Player

## 설명

`savePlayerSpawnPoint`은(는) 현재 객체 상태를 나타내는 `PlayerSpawnPoint` 프로퍼티입니다. 연관 API 호출 전후 상태 판단 기준으로 사용합니다. 후속 로직에서는 값 반영 시점과 참조 유효성을 함께 확인해야 합니다.  

`savePlayerSpawnPoint` 값은 식별 및 검색 기준으로 쓰이므로, 저장/동기화 데이터와 동일한 규칙으로 관리해야 참조 불일치를 줄일 수 있습니다.  

멀티플레이에서는 `savePlayerSpawnPoint`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: savePlayerSpawnPoint
- **타입**: PlayerSpawnPoint
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.savePlayerSpawnPoint
    this.scriptObject:Log(tostring(value))
end
```
