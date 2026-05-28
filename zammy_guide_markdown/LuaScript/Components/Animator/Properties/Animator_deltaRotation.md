---
title: deltaRotation
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_deltaRotation
source_path: LuaScript/Components/Animator/Properties/Animator_deltaRotation.html
last_updated: "2026.04.06 오후 02:49"
---

# deltaRotation

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 마지막으로 평가된 프레임에 대한 아바타의 델타 회전을 가져옵니다. 이 값은 애니메이션의 변화를 반영하며, 애니메이션의 상태에 따라 달라질 수 있습니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 애니메이션의 회전 상태를 확인할 때 유용하게 사용됩니다.

## 프로퍼티 정의

- **이름**: `deltaRotation`
- **타입**: [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local deltaRotation = animator.deltaRotation
```

## 참고 사항
