---
title: attachedRigidbody
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Properties/Collider_attachedRigidbody
source_path: LuaScript/Components/Collider/Properties/Collider_attachedRigidbody.html
last_updated: "2026.04.06 오후 02:51"
---

# attachedRigidbody

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 프로퍼티는 콜라이더가 부착된 리지드바디를 반환합니다. 리지드바디는 물리적 상호작용을 처리하는 객체로, 콜라이더와 함께 사용되어 물리 엔진의 기능을 활용할 수 있습니다. 이 프로퍼티는 읽기 전용이며, 리지드바디가 없는 경우에는 `nil`을 반환할 수 있습니다.

## 프로퍼티 정의

- **이름**: `attachedRigidbody`
- **타입**: `Rigidbody`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local rigidbody = collider.attachedRigidbody
```

## 참고 사항

동기화 미지원
