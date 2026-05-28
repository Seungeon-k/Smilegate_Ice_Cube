---
title: isStopped
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isStopped
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isStopped.html
last_updated: "2026.04.06 오후 02:53"
---

# isStopped

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템이 정지 상태인지 여부를 결정합니다. 이 값을 통해 파티클 시스템이 현재 작동 중인지, 아니면 정지 상태인지 확인할 수 있습니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 이 프로퍼티를 통해 상태를 확인한 후, 필요에 따라 다른 메서드를 사용하여 파티클 시스템을 제어해야 합니다.

## 프로퍼티 정의

- **이름**: `isStopped`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isStopped = particleSystem.isStopped
```

## 참고 사항
