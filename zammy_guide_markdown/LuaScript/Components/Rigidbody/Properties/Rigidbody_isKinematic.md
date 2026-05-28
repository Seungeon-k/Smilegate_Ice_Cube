---
title: isKinematic
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Properties/Rigidbody_isKinematic
source_path: LuaScript/Components/Rigidbody/Properties/Rigidbody_isKinematic.html
last_updated: "2026.04.06 오후 02:55"
---

# isKinematic

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 프로퍼티는 물리 엔진이 리지드바디에 영향을 미치는지를 제어합니다. `isKinematic`이 `true`로 설정되면, 리지드바디는 물리적 힘이나 충돌에 영향을 받지 않으며, 스크립트에서 직접 위치와 회전을 제어할 수 있습니다. 반대로 `false`로 설정하면, 물리 엔진의 영향을 받게 됩니다.

이 프로퍼티를 사용할 때는 리지드바디의 물리적 동작을 고려해야 하며, `isKinematic`을 변경하는 경우 물리적 상호작용에 영향을 줄 수 있습니다.

## 프로퍼티 정의

- **이름**: `isKinematic`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local isKinematic = rigidbody.isKinematic
rigidbody.isKinematic = true
```

## 참고 사항

동기화 지원
