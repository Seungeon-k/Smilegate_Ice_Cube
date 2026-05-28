---
title: Pause
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Pause
source_path: LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Pause.html
last_updated: "2026.04.06 오후 02:53"
---

# Pause

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 함수는 시스템을 일시 정지하여 새로운 입자가 생성되지 않도록 하고 기존 입자도 업데이트되지 않도록 합니다. 이 메서드를 호출하면 입자 시스템의 상태가 변경되며, 이후 다시 재개할 수 있습니다. 사용 시 주의할 점은, 일시 정지 상태에서 입자 시스템이 더 이상 작동하지 않으므로, 필요한 경우 재개 메서드를 호출해야 합니다.

이 함수는 파티클 시스템을 일시 정지하여 새로운 파티클이 방출되지 않도록 하고, 기존의 파티클도 업데이트되지 않도록 합니다. 이때, 자식 파티클 시스템도 함께 일시 정지할 수 있습니다.

## 함수

Pause()  
  

Pause(withChildren)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `boolean` | `withChildren` | 모든 자식 파티클 시스템도 일시 정지 |

### 반환값

없음

## 예제 코드

```lua
ParticleSystem:Pause(withChildren)
```
