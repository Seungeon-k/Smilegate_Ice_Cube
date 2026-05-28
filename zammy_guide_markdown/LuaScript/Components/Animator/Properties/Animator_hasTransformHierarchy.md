---
title: hasTransformHierarchy
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_hasTransformHierarchy
source_path: LuaScript/Components/Animator/Properties/Animator_hasTransformHierarchy.html
last_updated: "2026.04.06 오후 02:49"
---

# hasTransformHierarchy

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 객체가 변환 계층을 가지고 있는지를 나타냅니다. 만약 객체가 변환 계층을 가지고 있다면 true를 반환합니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 사용 시 주의할 점은 이 프로퍼티가 동기화를 지원하지 않으므로, 멀티스레드 환경에서의 사용은 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `hasTransformHierarchy`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local hasTransformHierarchy = animator.hasTransformHierarchy
```

## 참고 사항
