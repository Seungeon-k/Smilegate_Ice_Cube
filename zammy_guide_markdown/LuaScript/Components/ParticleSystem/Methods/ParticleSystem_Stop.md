---
title: Stop
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Stop
source_path: LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Stop.html
last_updated: "2026.04.06 오후 02:53"
---

# Stop

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 함수는 파티클 시스템의 재생을 중지합니다. 사용자가 지정한 중지 동작에 따라 파티클 시스템이 멈추게 됩니다. 이 함수는 파라미터가 없으며, 호출 시 즉시 파티클 시스템의 재생을 중지합니다. 예외 케이스는 없으며, 항상 정상적으로 작동합니다.

이 함수는 제공된 중지 동작을 사용하여 파티클 시스템의 재생을 중지합니다. `withChildren` 인수를 통해 모든 자식 파티클 시스템도 함께 중지할 수 있습니다. 이 함수는 파티클 시스템이 재생 중일 때 호출해야 하며, 이미 중지된 상태에서는 아무런 효과가 없습니다.

이 함수는 지정된 정지 동작을 사용하여 파티클 시스템의 재생을 중지합니다. `withChildren` 매개변수를 `true`로 설정하면 모든 자식 파티클 시스템도 함께 중지됩니다. `stopBehavior` 매개변수는 파티클 시스템이 어떻게 중지될지를 결정합니다. 예를 들어, `StopEmittingAndClear`를 선택하면 현재 방출 중인 모든 파티클이 제거됩니다. 반면, `StopEmitting`을 선택하면 새로운 파티클의 방출만 중지되고 기존 파티클은 만료될 때까지 남아 있습니다.

## 함수

Stop()  
  

Stop(withChildren)  
  

Stop(withChildren, stopBehavior)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `boolean` | `withChildren` | 모든 자식 파티클 시스템도 중지 방출을 중지하거나 방출을 중지하고 시스템을 지웁니다 |

### 반환값

없음

## 예제 코드

```lua
ParticleSystem:Stop(withChildren, stopBehavior)
```
