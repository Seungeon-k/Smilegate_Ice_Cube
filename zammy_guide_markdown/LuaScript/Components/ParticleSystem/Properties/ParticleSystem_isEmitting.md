---
title: isEmitting
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isEmitting
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isEmitting.html
last_updated: "2026.04.06 오후 02:53"
---

# isEmitting

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템이 파티클을 방출하고 있는지를 결정합니다. 파티클 시스템은 방출 모듈이 완료되었거나, 일시 정지되었거나, Stop 메서드를 호출하여 StopEmitting 플래그와 함께 중지된 경우 방출을 중단할 수 있습니다. 방출을 재개하려면 Play 메서드를 호출해야 합니다.

## 프로퍼티 정의

- **이름**: `isEmitting`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isEmitting = particleSystem.isEmitting
```

## 참고 사항
