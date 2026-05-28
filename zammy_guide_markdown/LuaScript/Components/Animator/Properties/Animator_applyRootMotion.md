---
title: applyRootMotion
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_applyRootMotion
source_path: LuaScript/Components/Animator/Properties/Animator_applyRootMotion.html
last_updated: "2026.04.06 오후 02:49"
---

# applyRootMotion

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 루트 모션이 적용될지를 결정합니다. 루트 모션은 애니메이션에서 캐릭터의 위치와 회전을 제어하는 데 사용됩니다. 이 프로퍼티가 true로 설정되면 애니메이션의 루트 모션이 적용되어 캐릭터가 애니메이션에 따라 이동합니다. 반대로 false로 설정하면 루트 모션이 적용되지 않습니다.

이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 따라서 애니메이터의 루트 모션 적용 여부를 확인하는 용도로만 사용됩니다.

## 프로퍼티 정의

- **이름**: `applyRootMotion`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local applyRootMotion = animator.applyRootMotion
```

## 참고 사항
