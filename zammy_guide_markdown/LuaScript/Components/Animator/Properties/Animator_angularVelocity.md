---
title: angularVelocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_angularVelocity
source_path: LuaScript/Components/Animator/Properties/Animator_angularVelocity.html
last_updated: "2026.04.06 오후 02:48"
---

# angularVelocity

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 마지막으로 평가된 프레임에 대한 아바타의 각속도를 가져옵니다. 각속도는 3차원 벡터([Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)) 형태로 반환되며, 이는 아바타의 회전 속도를 나타냅니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다.

각속도는 애니메이션의 동작을 이해하는 데 유용하며, 물리적 상호작용이나 애니메이션 효과를 조정하는 데 활용될 수 있습니다. 이 프로퍼티를 사용할 때는 애니메이션이 평가된 후에 값을 읽어야 하며, 그렇지 않으면 올바른 값을 얻지 못할 수 있습니다.

## 프로퍼티 정의

- **이름**: `angularVelocity`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local angularVelocity = animator.angularVelocity
```

## 참고 사항
