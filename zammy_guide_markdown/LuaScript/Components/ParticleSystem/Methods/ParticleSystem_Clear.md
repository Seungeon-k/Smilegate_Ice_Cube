---
title: Clear
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Clear
source_path: LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Clear.html
last_updated: "2026.04.06 오후 02:53"
---

# Clear

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 함수는 파티클 시스템 내의 모든 파티클을 제거합니다. 호출 후에는 파티클 시스템이 비어 있게 되며, 새로운 파티클이 생성될 때까지 대기 상태가 됩니다. 이 함수는 파티클 시스템의 상태를 초기화하는 데 유용합니다.

이 함수는 파티클 시스템 내의 모든 파티클을 제거합니다. `withChildren` 인수를 `true`로 설정하면 모든 자식 파티클 시스템도 함께 제거됩니다. 이 함수는 파티클 시스템을 초기 상태로 되돌리는 데 유용합니다. 사용 시 주의할 점은, 이 함수를 호출하면 현재 진행 중인 모든 파티클이 즉시 사라지므로, 필요할 경우 상태를 저장해 두는 것이 좋습니다.

## 함수

Clear()  
  

Clear(withChildren)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `boolean` | `withChildren` | 모든 자식 파티클 시스템도 제거할지 여부 |

### 반환값

없음

## 예제 코드

```lua
ParticleSystem:Clear(withChildren)
```
