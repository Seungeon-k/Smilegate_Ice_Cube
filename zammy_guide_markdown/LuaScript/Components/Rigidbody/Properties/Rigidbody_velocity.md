---
title: velocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Properties/Rigidbody_velocity
source_path: LuaScript/Components/Rigidbody/Properties/Rigidbody_velocity.html
last_updated: "2026.04.06 오후 02:55"
---

# velocity

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 프로퍼티는 강체의 속도 벡터를 나타냅니다. 이는 강체의 위치 변화 속도를 표현합니다. 속도는 물리적 시뮬레이션에서 중요한 요소로, 강체의 움직임을 제어하는 데 사용됩니다.

속도를 설정할 때는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형식의 값을 사용해야 하며, 이 값은 강체의 x, y, z 방향의 속도를 나타냅니다. 속도를 직접 변경하면 강체의 물리적 행동에 즉각적인 영향을 미치므로 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `velocity`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
rigidbody.velocity
```

## 참고 사항

동기화 지원
