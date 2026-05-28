---
title: constraints
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Properties/Rigidbody_constraints
source_path: LuaScript/Components/Rigidbody/Properties/Rigidbody_constraints.html
last_updated: "2026.04.06 오후 02:55"
---

# constraints

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 프로퍼티는 Rigidbody의 시뮬레이션에서 허용되는 자유도(degrees of freedom)를 제어합니다. 사용자는 이 프로퍼티를 통해 Rigidbody의 움직임과 회전을 제한할 수 있습니다. 예를 들어, 특정 축에 대한 움직임이나 회전을 동결할 수 있습니다.

제한할 수 있는 옵션으로는 X, Y, Z 축에 대한 동결이 있으며, 모든 축에 대해 동결할 수도 있습니다. 이 프로퍼티를 설정할 때는 주의가 필요하며, 잘못된 설정은 의도하지 않은 물리적 동작을 초래할 수 있습니다.

## 프로퍼티 정의

- **이름**: `constraints`
- **타입**: `RigidbodyConstraints`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
rigidbody.constraints = RigidbodyConstraints.None
rigidbody.constraints = RigidbodyConstraints.FreezePositionX
rigidbody.constraints = RigidbodyConstraints.FreezePositionY
rigidbody.constraints = RigidbodyConstraints.FreezePositionZ
rigidbody.constraints = RigidbodyConstraints.FreezePosition
rigidbody.constraints = RigidbodyConstraints.FreezeRotationX
rigidbody.constraints = RigidbodyConstraints.FreezeRotationY
rigidbody.constraints = RigidbodyConstraints.FreezeRotationZ
rigidbody.constraints = RigidbodyConstraints.FreezeRotation
rigidbody.constraints = RigidbodyConstraints.FreezeAll
```

## 참고 사항

동기화 지원
