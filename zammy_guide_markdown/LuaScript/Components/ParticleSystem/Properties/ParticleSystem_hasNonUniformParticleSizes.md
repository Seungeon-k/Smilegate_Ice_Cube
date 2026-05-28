---
title: hasNonUniformParticleSizes
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_hasNonUniformParticleSizes
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_hasNonUniformParticleSizes.html
last_updated: "2026.04.06 오후 02:53"
---

# hasNonUniformParticleSizes

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템이 너비와 높이(그리고 메시를 사용할 때 깊이)에 대해 단일 값을 사용하는지, 아니면 각 축에 대해 서로 다른 값을 지정하는지를 결정합니다.

이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 따라서 파티클 시스템의 설정에 따라 이 값을 확인하여 파티클의 크기 조정 방식에 대한 정보를 얻을 수 있습니다.

## 프로퍼티 정의

- **이름**: `hasNonUniformParticleSizes`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local hasNonUniformParticleSizes = particleSystem.hasNonUniformParticleSizes
```

## 참고 사항
