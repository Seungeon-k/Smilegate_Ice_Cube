---
title: PlayerSpawnPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerSpawnPoint
source_path: LuaScript/VObjects/PlayerSpawnPoint.html
last_updated: "2026.04.06 오후 03:35"
---

# PlayerSpawnPoint

## 모듈

> VFramework

## 개요

`PlayerSpawnPoint`는 [`WorldObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject)를 상속받는 객체로, 게임 내에서 플레이어 캐릭터의 시작 위치(Spawn Point)를 정의하고 관리하는 클래스입니다.  

이 모듈은 씬(scene) 내 여러 스폰 지점 중 하나를 선택하거나, 특정 조건(예: 팀, 지역, 게임 모드 등)에 따라 플레이어를 적절한 위치에 배치에 사용할 수 있습니다.

주로 다음과 같은 상황에서 사용됩니다:  

게임 시작 시: 플레이어를 초기 위치에 배치할 때  

리스폰(Respawn) 시: 플레이어의 재등장할 위치를 결정할 때

## 메서드

| 메서드명 | 설명 | 반환값 |
| --- | --- | --- |

## 예제 코드

```lua
local serviceApi
local script

function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject
end

function this.OnTriggerEnter(collider)

    local character = collider.vObject:Cast("Character")
    if character == nil then
        return
    end

    -- 먼저 캐릭터가 가진 스폰포인트 확인
    local playerSpawnPoint = character.startPlayerSpawnPoint

    -- 없다면 World에서 가져오기
    if playerSpawnPoint == nil then
        playerSpawnPoint = serviceApi.world:GetVObjectByTypeName("PlayerSpawnPoint")
    end

    if playerSpawnPoint == nil then
        return
    end

    local player = character.player
    if player == nil then
        return
    end

    character:Respawn(playerSpawnPoint)
end
```
