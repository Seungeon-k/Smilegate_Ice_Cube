---
title: targetRotation
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_targetRotation
source_path: LuaScript/Components/Animator/Properties/Animator_targetRotation.html
last_updated: "2026.04.06 오후 02:49"
---

# targetRotation

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 `SetTarget`으로 지정된 타겟의 회전을 반환합니다. 이 값은 읽기 전용이며, 직접적으로 설정할 수 없습니다. 사용 시 주의할 점은 이 프로퍼티가 동기화되지 않으므로, 멀티스레드 환경에서의 사용은 권장되지 않습니다.

## 프로퍼티 정의

- **이름**: `targetRotation`
- **타입**: [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local rotation = animator.targetRotation
```

## 참고 사항
