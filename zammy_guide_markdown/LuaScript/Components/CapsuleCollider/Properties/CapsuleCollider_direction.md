---
title: direction
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_direction
source_path: LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_direction.html
last_updated: "2026.04.06 오후 02:51"
---

# direction

## 객체

> [CapsuleCollider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/CapsuleCollider)

## 설명

이 프로퍼티는 캡슐의 방향을 나타냅니다. 캡슐의 방향은 정수형으로 표현되며, 0은 Y축 방향, 1은 X축 방향, 2는 Z축 방향을 의미합니다. 이 값을 설정하거나 가져올 수 있으며, 캡슐의 물리적 특성에 영향을 미칠 수 있습니다.

사용 시 주의할 점은 캡슐의 방향을 변경하면 물리적 상호작용에 영향을 줄 수 있으므로, 적절한 상황에서만 변경해야 합니다. 또한, 이 프로퍼티는 동기화가 지원되므로 멀티스레드 환경에서도 안전하게 사용할 수 있습니다.

## 프로퍼티 정의

- **이름**: `direction`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local direction = capsuleCollider.direction
capsuleCollider.direction = newDirection
```

## 참고 사항

동기화 지원
