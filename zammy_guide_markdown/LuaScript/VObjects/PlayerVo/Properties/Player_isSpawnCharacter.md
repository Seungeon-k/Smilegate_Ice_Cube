---
title: isSpawnCharacter
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Properties/Player_isSpawnCharacter
source_path: LuaScript/VObjects/PlayerVo/Properties/Player_isSpawnCharacter.html
last_updated: "2026.04.06 오후 03:36"
---

# isSpawnCharacter

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`isSpawnCharacter`는 해당 플레이어가 현재 월드에 캐릭터 인스턴스를 생성한 상태인지 나타냅니다.  

매치 시작/부활/관전 전환 시점에서 값이 바뀌며, `false`일 때는 캐릭터 기준 입력/카메라 로직을 건너뛰어 null 참조를 방지해야 합니다.  

네트워크 지연 구간에서는 서버 반영 시점과 로컬 예측 시점이 다를 수 있으므로 `player.character` 존재 여부와 함께 이중 확인하는 방식이 안전합니다.

## 프로퍼티 정의

- **이름**: isSpawnCharacter
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
function this.OnStart()
    local player = this.serviceApi.playerService.localPlayer
    if player ~= nil then
        this.scriptObject:Log("spawned character = " .. tostring(player.isSpawnCharacter))
    end
end
```
