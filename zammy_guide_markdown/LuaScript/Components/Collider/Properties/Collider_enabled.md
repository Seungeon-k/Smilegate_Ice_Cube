---
title: enabled
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Properties/Collider_enabled
source_path: LuaScript/Components/Collider/Properties/Collider_enabled.html
last_updated: "2026.04.06 오후 02:51"
---

# enabled

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 프로퍼티는 Collider의 활성화 상태를 제어합니다. 활성화된 Collider는 다른 Collider와 충돌하며, 비활성화된 Collider는 충돌하지 않습니다. 이 프로퍼티를 사용하여 게임 오브젝트의 물리적 상호작용을 동적으로 조정할 수 있습니다.

비활성화된 Collider는 물리적 상호작용에서 제외되므로, 게임 로직에 따라 적절히 활성화 및 비활성화하는 것이 중요합니다. 예를 들어, 특정 상황에서만 충돌이 필요할 때 이 프로퍼티를 활용할 수 있습니다.

## 프로퍼티 정의

- **이름**: `enabled`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
collider.enabled
```

## 참고 사항

동기화 지원
