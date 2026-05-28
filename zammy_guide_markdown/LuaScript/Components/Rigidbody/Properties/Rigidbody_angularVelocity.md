---
title: angularVelocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Properties/Rigidbody_angularVelocity
source_path: LuaScript/Components/Rigidbody/Properties/Rigidbody_angularVelocity.html
last_updated: "2026.04.06 오후 02:55"
---

# angularVelocity

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 프로퍼티는 리지드바디의 각속도 벡터를 나타내며, 단위는 초당 라디안입니다. 각속도는 물체의 회전 속도를 나타내며, 물체의 회전 운동을 제어하는 데 사용됩니다.

각속도를 설정하거나 가져올 때는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형식으로 값을 사용해야 합니다. 이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 현재 각속도를 확인하거나 새로운 값을 설정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `angularVelocity`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local angularVelocity = rigidbody.angularVelocity
rigidbody.angularVelocity = newAngularVelocity
```

## 참고 사항

동기화 지원
