---
title: fireEvents
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_fireEvents
source_path: LuaScript/Components/Animator/Properties/Animator_fireEvents.html
last_updated: "2026.04.06 오후 02:49"
---

# fireEvents

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 Animator가 AnimationEvent 유형의 이벤트를 전송할지 여부를 설정합니다. 기본적으로 이 값을 true로 설정하면 Animator가 애니메이션 이벤트를 발생시킵니다. 이 프로퍼티를 false로 설정하면 Animator는 이벤트를 전송하지 않습니다.

사용 시 주의할 점은, 이 프로퍼티가 true로 설정되어 있을 때 AnimationEvent가 발생하는지 확인해야 한다는 것입니다. 이벤트가 발생하지 않도록 설정할 경우, 애니메이션의 특정 동작이 누락될 수 있습니다.

## 프로퍼티 정의

- **이름**: `fireEvents`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
animator.fireEvents = true
animator.fireEvents = false
```

## 참고 사항

동기화 지원
