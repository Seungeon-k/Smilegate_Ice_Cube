---
title: time
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem/Properties/ParticleSystem_time
source_path: LuaScript/Components/ParticleSystem/Properties/ParticleSystem_time.html
last_updated: "2026.04.06 오후 02:53"
---

# time

## 객체

> [ParticleSystem](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/ParticleSystem)

## 설명

이 프로퍼티는 파티클 시스템의 재생 위치를 초 단위로 반환합니다. 이 값을 통해 현재 파티클 시스템이 재생되고 있는 시간 정보를 알 수 있습니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 이 값을 직접 변경하려고 하면 예외가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `time`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local time = particleSystem.time
```

## 참고 사항
