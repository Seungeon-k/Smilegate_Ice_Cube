---
title: SpawnCharacter
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Methods/Player_SpawnCharacter_PlayerVo_PlayerSpawnPointVo
source_path: LuaScript/VObjects/PlayerVo/Methods/Player_SpawnCharacter_PlayerVo_PlayerSpawnPointVo.html
last_updated: "2026.04.06 오후 03:36"
---

# SpawnCharacter

## 객체

> Player

## 설명

SpawnCharacter 메서드는 spawnPoint 기준으로 새 인스턴스 생성 흐름을 수행합니다.  

`SpawnCharacter`는 지정 스폰 포인트를 기준으로 플레이어 캐릭터를 생성(또는 재생성)합니다. 스폰 직후 카메라 타깃, 입력 차단 해제, UI 초기화 순서를 고정하면 멀티플레이 재스폰 시점의 상태 불일치를 줄일 수 있습니다.  

`SpawnCharacter`를 여러 스크립트가 동시에 호출하면 결과가 덮어써질 수 있으므로, 호출 주체를 명확히 분리해 관리하세요.

## 함수

SpawnCharacter(spawnPoint)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [PlayerSpawnPoint](../../PlayerSpawnPoint.md) | spawnPoint | `spawnPoint`는 [`PlayerSpawnPoint`](../../PlayerSpawnPoint.md) 객체 참조입니다. 대상 객체가 파괴/비활성화되지 않았는지 확인하고, 필요한 경우 `nil` 예외 분기를 포함하세요. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    local spawnPoint = target.startPlayerSpawnPoint
    if spawnPoint ~= nil then
        target:SpawnCharacter(spawnPoint)
    end
end
```
