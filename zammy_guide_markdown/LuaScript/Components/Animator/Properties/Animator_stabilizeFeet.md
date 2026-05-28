---
title: stabilizeFeet
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_stabilizeFeet
source_path: LuaScript/Components/Animator/Properties/Animator_stabilizeFeet.html
last_updated: "2026.04.06 오후 02:49"
---

# stabilizeFeet

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 전환 및 블렌딩 중 발의 자동 안정화를 제어합니다. 발의 위치가 자연스럽게 유지되도록 하여 애니메이션의 품질을 향상시킵니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 사용 시 주의할 점은 발의 안정화가 항상 필요한 것은 아니며, 특정 애니메이션 상황에서는 비활성화하는 것이 더 나은 결과를 가져올 수 있습니다.

## 프로퍼티 정의

- **이름**: `stabilizeFeet`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local stabilizeFeet = animator.stabilizeFeet
```

## 참고 사항
