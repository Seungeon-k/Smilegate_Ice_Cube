---
title: bodyPosition
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_bodyPosition
source_path: LuaScript/Components/Animator/Properties/Animator_bodyPosition.html
last_updated: "2026.04.06 오후 02:49"
---

# bodyPosition

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 신체 중심의 질량 위치를 나타냅니다. 이 값을 통해 애니메이션의 물리적 상호작용을 조정할 수 있습니다.

이 프로퍼티는 읽기 전용이며, 직접적으로 값을 설정할 수 없습니다. 따라서 애니메이션의 상태에 따라 이 값을 변경하는 것은 불가능합니다.

## 프로퍼티 정의

- **이름**: `bodyPosition`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local position = animator.bodyPosition
```

## 참고 사항
