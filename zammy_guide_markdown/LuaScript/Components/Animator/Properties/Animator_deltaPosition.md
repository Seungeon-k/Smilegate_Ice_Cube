---
title: deltaPosition
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_deltaPosition
source_path: LuaScript/Components/Animator/Properties/Animator_deltaPosition.html
last_updated: "2026.04.06 오후 02:49"
---

# deltaPosition

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 마지막으로 평가된 프레임에 대한 아바타의 델타 위치를 가져옵니다. 이 값은 애니메이션의 변화를 반영하며, 애니메이션의 진행에 따라 달라질 수 있습니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 애니메이션의 위치를 직접 수정할 수는 없습니다.

## 프로퍼티 정의

- **이름**: `deltaPosition`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local deltaPosition = animator.deltaPosition
```

## 참고 사항
