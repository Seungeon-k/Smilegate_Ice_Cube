---
title: rootRotation
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_rootRotation
source_path: LuaScript/Components/Animator/Properties/Animator_rootRotation.html
last_updated: "2026.04.06 오후 02:49"
---

# rootRotation

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 게임 오브젝트의 루트 회전을 나타냅니다. 루트 회전은 게임 오브젝트의 회전 상태를 나타내며, [Quaternion](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion) 형식으로 반환됩니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다.

루트 회전은 애니메이션 시스템에서 중요한 역할을 하며, 게임 오브젝트의 회전 상태를 제어하는 데 사용됩니다. 이 프로퍼티를 통해 현재 회전 상태를 확인할 수 있습니다.

예외 케이스는 없으며, 이 프로퍼티는 항상 유효한 [Quaternion](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion) 값을 반환합니다.

## 프로퍼티 정의

- **이름**: `rootRotation`
- **타입**: [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local rotation = animator.rootRotation
```

## 참고 사항

동기화 미지원
