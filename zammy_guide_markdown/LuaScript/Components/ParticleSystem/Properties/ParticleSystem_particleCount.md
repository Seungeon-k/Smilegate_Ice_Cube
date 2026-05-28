---
title: particleCount
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_particleCount
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_particleCount.html
last_updated: "2026.04.06 오후 02:53"
---

# particleCount

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 현재 파티클 시스템에서 활성화된 파티클의 수를 반환합니다. 반환되는 수치는 자식 파티클 시스템의 파티클 수를 포함하지 않습니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 사용 시 주의해야 할 점은, 이 값이 자식 파티클 시스템의 파티클 수를 포함하지 않기 때문에, 전체 파티클 수를 알고 싶다면 자식 시스템을 별도로 확인해야 한다는 것입니다.

## 프로퍼티 정의

- **이름**: `particleCount`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local count = particleSystem.particleCount
```

## 참고 사항
