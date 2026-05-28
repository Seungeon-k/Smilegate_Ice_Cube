---
title: gravityWeight
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_gravityWeight
source_path: LuaScript/Components/Animator/Properties/Animator_gravityWeight.html
last_updated: "2026.04.06 오후 02:49"
---

# gravityWeight

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

현재 재생 중인 애니메이션에 기반한 중력 가중치를 나타냅니다. 이 프로퍼티는 읽기 전용이며, 애니메이션의 상태에 따라 값이 변경됩니다. 따라서 이 값을 직접 설정할 수는 없습니다.

이 프로퍼티를 사용할 때는 애니메이션이 활성화되어 있어야 올바른 값을 반환합니다. 애니메이션이 비활성화되거나 중지된 경우, 반환되는 값은 예측할 수 없으므로 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `gravityWeight`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local gravityWeight = animator.gravityWeight
```

## 참고 사항
