---
title: useAutoRandomSeed
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_useAutoRandomSeed
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_useAutoRandomSeed.html
last_updated: "2026.04.06 오후 02:53"
---

# useAutoRandomSeed

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템이 자동으로 생성된 난수로 난수 생성기를 초기화할지 여부를 제어합니다. 기본적으로 이 값을 설정하면 파티클 시스템이 매번 동일한 시퀀스의 난수를 생성하지 않도록 합니다.

이 프로퍼티를 사용하여 파티클의 랜덤성을 조절할 수 있으며, 특정 효과를 위해 난수 생성 방식을 변경할 수 있습니다.

예외 케이스는 없으며, 이 프로퍼티는 항상 Boolean 값을 반환합니다.

## 프로퍼티 정의

- **이름**: `useAutoRandomSeed`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local useAutoRandomSeed = ParticleSystem.useAutoRandomSeed
ParticleSystem.useAutoRandomSeed = true
```

## 참고 사항

동기화 지원
