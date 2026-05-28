---
title: speed
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_speed
source_path: LuaScript/Components/Animator/Properties/Animator_speed.html
last_updated: "2026.04.06 오후 02:49"
---

# speed

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 Animator의 재생 속도를 설정하거나 가져오는 데 사용됩니다. 기본값은 1로, 이는 정상 재생 속도를 의미합니다. 속도를 조정함으로써 애니메이션의 재생 속도를 빠르게 하거나 느리게 할 수 있습니다.

속도를 0으로 설정하면 애니메이션이 정지합니다. 이 프로퍼티는 실시간으로 애니메이션의 재생 속도를 변경할 수 있으므로, 게임의 상황에 따라 동적으로 조정할 수 있습니다.

예외적으로, Animator가 비활성화된 상태에서는 속도를 변경해도 효과가 없을 수 있습니다. 또한, 속도를 너무 높게 설정하면 애니메이션이 부자연스럽게 보일 수 있으니 주의해야 합니다.

## 프로퍼티 정의

- **이름**: `speed`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
value = animator.speed
animator.speed = value
```

## 참고 사항
