---
title: wrapMode
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Properties/Animation_wrapMode
source_path: LuaScript/Components/Animation/Properties/Animation_wrapMode.html
last_updated: "2026.04.06 오후 02:48"
---

# wrapMode

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 프로퍼티는 애니메이션 클립의 재생 범위를 넘어선 시간 처리를 정의합니다. 사용자는 애니메이션이 끝난 후의 동작을 설정할 수 있습니다.

지원되는 값은 다음과 같습니다:

- **Default**: 상위에서 설정된 기본 반복 모드를 읽습니다.
- **Once**: 애니메이션 클립의 끝에 도달하면 자동으로 재생이 중지되고, 시간은 클립의 시작으로 리셋됩니다.
- **Clamp**: 애니메이션이 끝나면 더 이상 진행되지 않습니다.
- **Loop**: 애니메이션이 끝나면 시작으로 돌아가 계속 진행됩니다.
- **PingPong**: 애니메이션이 끝나면 시작과 끝 사이에서 ping pong 방식으로 진행됩니다.
- **ClampForever**: 애니메이션이 끝나면 마지막 프레임을 계속 재생하며 절대 중지하지 않습니다.

이 프로퍼티를 설정할 때는 적절한 `WrapMode` 값을 사용해야 하며, 잘못된 값이 설정될 경우 예기치 않은 동작이 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `wrapMode`
- **타입**: `WrapMode`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
value = Animation.wrapMode
Animation.wrapMode = value
```

## 참고 사항

동기화 지원
