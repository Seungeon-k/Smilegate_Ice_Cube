---
title: totalTime
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_totalTime
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_totalTime.html
last_updated: "2026.04.06 오후 02:53"
---

# totalTime

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템의 총 재생 시간을 초 단위로 반환합니다. 이 값은 시작 지연 설정을 포함합니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 사용 시 주의해야 할 점은 이 값이 파티클 시스템의 상태에 따라 달라질 수 있다는 것입니다. 예를 들어, 파티클 시스템이 재생 중일 때와 정지 중일 때의 값이 다를 수 있습니다.

## 프로퍼티 정의

- **이름**: `totalTime`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local totalTime = particleSystem.totalTime
```

## 참고 사항
