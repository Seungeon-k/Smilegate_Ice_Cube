---
title: Play
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Play
source_path: LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Play.html
last_updated: "2026.04.06 오후 02:53"
---

# Play

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 함수는 파티클 시스템을 시작합니다. 호출 시 파티클 효과가 재생되며, 현재 상태에 따라 이전에 중지된 파티클이 다시 나타납니다. 이 함수는 인수가 필요하지 않으며, 파티클 시스템이 활성화된 상태에서만 효과적으로 작동합니다. 만약 파티클 시스템이 비활성화된 상태라면, 이 함수를 호출해도 아무런 효과가 없습니다.

이 함수는 파티클 시스템을 시작합니다. `withChildren` 인수를 `true`로 설정하면 모든 자식 파티클 시스템도 함께 재생됩니다. 이 함수는 파티클 시스템이 비활성 상태일 때 호출할 수 있으며, 호출 후에는 파티클이 생성되기 시작합니다. 예외 케이스는 없으며, 인수에 따라 동작이 달라질 수 있습니다.

## 함수

Play()  
  

Play(withChildren)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `boolean` | `withChildren` | 모든 자식 파티클 시스템도 재생할지 여부 |

### 반환값

없음

## 예제 코드

```lua
ParticleSystem:Play(withChildren)
```
