---
title: useGravity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Properties/Rigidbody_useGravity
source_path: LuaScript/Components/Rigidbody/Properties/Rigidbody_useGravity.html
last_updated: "2026.04.06 오후 02:55"
---

# useGravity

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 프로퍼티는 이 리지드바디에 중력이 영향을 미치는지를 제어합니다. 기본적으로 중력이 적용되며, 이 값을 false로 설정하면 중력이 적용되지 않습니다.

이 프로퍼티를 설정할 때는 리지드바디가 활성 상태여야 하며, 비활성 상태에서는 설정이 무시될 수 있습니다. 또한, 중력을 비활성화하면 물리적 상호작용이 달라질 수 있으므로 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `useGravity`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
rigidbody.useGravity
```

## 참고 사항

동기화 지원
