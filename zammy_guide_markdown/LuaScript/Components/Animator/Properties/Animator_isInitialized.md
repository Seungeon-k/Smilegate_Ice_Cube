---
title: isInitialized
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_isInitialized
source_path: LuaScript/Components/Animator/Properties/Animator_isInitialized.html
last_updated: "2026.04.06 오후 02:49"
---

# isInitialized

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 애니메이터가 성공적으로 초기화되었는지를 반환합니다. 초기화가 완료되지 않은 상태에서 애니메이터를 사용하려고 하면 예기치 않은 동작이 발생할 수 있습니다. 따라서 이 프로퍼티를 통해 애니메이터의 초기화 상태를 확인한 후에 관련 작업을 수행하는 것이 좋습니다.

## 프로퍼티 정의

- **이름**: `isInitialized`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isInitialized = animator.isInitialized
```

## 참고 사항
