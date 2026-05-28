---
title: randomSeed
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_randomSeed
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_randomSeed.html
last_updated: "2026.04.06 오후 02:53"
---

# randomSeed

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템의 방출에 사용되는 랜덤 시드를 재정의합니다. 랜덤 시드를 설정하면 파티클의 생성 및 동작이 예측 가능해지며, 동일한 시드를 사용하면 동일한 결과를 얻을 수 있습니다.

이 프로퍼티는 읽기 및 쓰기가 가능하며, 파티클 시스템의 동작에 영향을 미칠 수 있으므로 주의해서 사용해야 합니다. 예를 들어, 시드를 변경하면 기존의 파티클이 어떻게 동작할지 예측할 수 없게 될 수 있습니다.

## 프로퍼티 정의

- **이름**: `randomSeed`
- **타입**: `UInt32`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
particleSystem.randomSeed
```

## 참고 사항

동기화 지원
