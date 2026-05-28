---
title: isTrigger
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Properties/Collider_isTrigger
source_path: LuaScript/Components/Collider/Properties/Collider_isTrigger.html
last_updated: "2026.04.06 오후 02:51"
---

# isTrigger

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 프로퍼티는 해당 충돌체가 트리거로 설정되어 있는지를 지정합니다. 트리거로 설정된 충돌체는 물리적 상호작용을 발생시키지 않으며, 대신 충돌 이벤트를 감지할 수 있습니다. 이 프로퍼티를 사용하여 게임 오브젝트의 충돌체가 트리거인지 여부를 동적으로 변경할 수 있습니다.

트리거로 설정된 충돌체는 일반적인 충돌 처리와는 다르게 작동하므로, 이를 사용할 때는 게임 로직에 맞게 적절히 설정해야 합니다. 예를 들어, 플레이어가 특정 영역에 들어갔을 때 이벤트를 발생시키고 싶다면 이 프로퍼티를 활용할 수 있습니다.

## 프로퍼티 정의

- **이름**: `isTrigger`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
collider.isTrigger
```

## 참고 사항

동기화 지원
