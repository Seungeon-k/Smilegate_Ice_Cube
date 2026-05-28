---
title: isHuman
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_isHuman
source_path: LuaScript/Components/Animator/Properties/Animator_isHuman.html
last_updated: "2026.04.06 오후 02:49"
---

# isHuman

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 현재 리그가 휴머노이드인지 여부를 반환합니다. 휴머노이드 리그일 경우 true를 반환하며, 일반 리그일 경우 false를 반환합니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 사용 시 주의해야 할 점은, 리그의 종류에 따라 반환 값이 달라질 수 있다는 것입니다.

## 프로퍼티 정의

- **이름**: `isHuman`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isHuman = animator.isHuman
```

## 참고 사항
