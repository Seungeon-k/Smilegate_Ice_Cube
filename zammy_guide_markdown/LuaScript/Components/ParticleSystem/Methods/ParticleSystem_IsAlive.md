---
title: IsAlive
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Methods/ParticleSystem_IsAlive
source_path: LuaScript/Components/ParticleSystem/Methods/ParticleSystem_IsAlive.html
last_updated: "2026.04.06 오후 02:53"
---

# IsAlive

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 함수는 파티클 시스템에 현재 살아있는 파티클이 존재하는지, 또는 새로운 파티클을 생성할 것인지를 확인합니다. 파티클 시스템이 파티클을 방출 중지하고 모든 파티클이 사라진 경우에는 false를 반환합니다. 이 메서드는 파티클 시스템의 상태를 확인하는 데 유용합니다.

이 함수는 파티클 시스템에 현재 살아있는 파티클이 있는지, 또는 더 많은 파티클을 생성할 것인지를 확인합니다. `withChildren` 인수를 `true`로 설정하면 모든 자식 파티클 시스템도 함께 검사합니다. 이 함수는 파티클 시스템이 더 이상 파티클을 방출하지 않고 모든 파티클이 죽어 있는 경우 `false`를 반환합니다.

## 함수

IsAlive()  
  

IsAlive(withChildren)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `boolean` | `withChildren` | 모든 자식 파티클 시스템도 검사 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 파티클 시스템에 살아있는 파티클이 있거나 새로운 파티클을 생성 중이면 true를 반환합니다. 파티클 시스템이 파티클 방출을 중지하고 모든 파티클이 사라진 경우 false를 반환 |

| **형식** | **설명** |
| --- | --- |
| boolean | 파티클 시스템에 살아있는 파티클이 있거나 새로운 파티클을 생성 중이면 true를 반환합니다. 파티클 시스템이 파티클 방출을 중지하고 모든 파티클이 사라진 경우 false를 반환 |

## 예제 코드

```lua
local isAlive = ParticleSystem:IsAlive(true)
```
