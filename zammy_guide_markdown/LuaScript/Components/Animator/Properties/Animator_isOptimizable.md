---
title: isOptimizable
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_isOptimizable
source_path: LuaScript/Components/Animator/Properties/Animator_isOptimizable.html
last_updated: "2026.04.06 오후 02:49"
---

# isOptimizable

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 현재 리그가 `AnimatorUtility.OptimizeTransformHierarchy`를 사용하여 최적화할 수 있는지를 나타냅니다. 최적화가 가능하면 `true`를 반환합니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 사용 시 주의할 점은 최적화 가능 여부가 리그의 상태에 따라 달라질 수 있다는 것입니다.

## 프로퍼티 정의

- **이름**: `isOptimizable`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isOptimizable = animator.isOptimizable
```

## 참고 사항

동기화 미지원
