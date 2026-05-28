---
title: bodyRotation
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_bodyRotation
source_path: LuaScript/Components/Animator/Properties/Animator_bodyRotation.html
last_updated: "2026.04.06 오후 02:49"
---

# bodyRotation

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 몸의 중심 질량의 회전을 나타냅니다. 회전 값은 [Quaternion](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion) 형식으로 반환되며, 이 값을 통해 애니메이션의 회전 상태를 제어할 수 있습니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 애니메이션의 회전 상태를 직접 변경하려면 다른 방법을 사용해야 합니다.

예외적으로, 이 프로퍼티에 접근할 때는 Animator가 활성화되어 있어야 하며, 그렇지 않을 경우 예상치 못한 결과가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `bodyRotation`
- **타입**: [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local rotation = animator.bodyRotation
```

## 참고 사항
