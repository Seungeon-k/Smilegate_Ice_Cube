---
title: hasRootMotion
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_hasRootMotion
source_path: LuaScript/Components/Animator/Properties/Animator_hasRootMotion.html
last_updated: "2026.04.06 오후 02:49"
---

# hasRootMotion

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

현재 리그가 루트 모션을 가지고 있는지 여부를 반환합니다. 이 프로퍼티는 애니메이션 시스템에서 루트 모션을 사용할 때 유용합니다. 루트 모션이 활성화된 경우, 캐릭터의 위치와 회전이 애니메이션에 의해 제어됩니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다.

루트 모션이 활성화된 경우에만 true를 반환하며, 그렇지 않으면 false를 반환합니다. 이 프로퍼티를 사용하여 애니메이션의 동작을 제어하거나, 루트 모션이 필요한지 여부를 판단할 수 있습니다.

## 프로퍼티 정의

- **이름**: `hasRootMotion`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local hasRootMotion = animator.hasRootMotion
```

## 참고 사항
