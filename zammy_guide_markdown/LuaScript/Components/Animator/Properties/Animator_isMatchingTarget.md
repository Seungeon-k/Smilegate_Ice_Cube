---
title: isMatchingTarget
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_isMatchingTarget
source_path: LuaScript/Components/Animator/Properties/Animator_isMatchingTarget.html
last_updated: "2026.04.06 오후 02:49"
---

# isMatchingTarget

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 자동 매칭이 활성화되어 있는지를 나타냅니다. 자동 매칭이 활성화되면, 애니메이션이 현재 목표와 일치하는지 여부를 확인할 수 있습니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 사용 시 주의할 점은 이 프로퍼티가 동기화되지 않으므로, 멀티스레드 환경에서의 사용은 권장되지 않습니다.

## 프로퍼티 정의

- **이름**: `isMatchingTarget`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isMatching = animator.isMatchingTarget
```

## 참고 사항

동기화 미지원
