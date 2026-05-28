---
title: velocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_velocity
source_path: LuaScript/Components/Animator/Properties/Animator_velocity.html
last_updated: "2026.04.06 오후 02:49"
---

# velocity

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 마지막으로 평가된 프레임에 대한 아바타의 속도를 가져옵니다. 속도는 3차원 벡터([Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)) 형태로 반환되며, 아바타의 움직임을 추적하는 데 유용합니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 사용 시 주의할 점은 이 값이 마지막 프레임의 속도를 반영하므로, 실시간으로 변하는 속도를 반영하지 않을 수 있습니다.

## 프로퍼티 정의

- **이름**: `velocity`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local velocity = animator.velocity
```

## 참고 사항
