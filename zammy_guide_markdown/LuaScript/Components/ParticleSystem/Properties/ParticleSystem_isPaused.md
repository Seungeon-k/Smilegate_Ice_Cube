---
title: isPaused
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isPaused
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isPaused.html
last_updated: "2026.04.06 오후 02:53"
---

# isPaused

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템이 일시 정지 상태인지 여부를 결정합니다. 이 값을 통해 파티클 시스템의 현재 상태를 확인할 수 있습니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 파티클 시스템을 일시 정지 상태로 변경하려면 다른 방법을 사용해야 합니다.

## 프로퍼티 정의

- **이름**: `isPaused`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isPaused = particleSystem.isPaused
```

## 참고 사항
