---
title: has3DParticleRotations
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_has3DParticleRotations
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_has3DParticleRotations.html
last_updated: "2026.04.06 오후 02:53"
---

# has3DParticleRotations

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템이 파티클을 Z축만 회전시키는지, 아니면 X, Y, Z축 각각에 대해 별도의 값을 지정하는지를 결정합니다. 이 값을 통해 파티클의 회전 방식에 대한 설정을 확인할 수 있습니다.

이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 따라서 값을 변경하려고 시도하면 예외가 발생하지 않지만, 변경이 반영되지 않습니다.

## 프로퍼티 정의

- **이름**: `has3DParticleRotations`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local has3DParticleRotations = particleSystem.has3DParticleRotations
```

## 참고 사항
