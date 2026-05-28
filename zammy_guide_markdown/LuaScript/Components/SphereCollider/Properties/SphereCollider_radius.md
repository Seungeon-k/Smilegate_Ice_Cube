---
title: radius
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/SphereCollider/Properties/SphereCollider_radius
source_path: LuaScript/Components/SphereCollider/Properties/SphereCollider_radius.html
last_updated: "2026.04.06 오후 02:55"
---

# radius

## 객체

> [SphereCollider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/SphereCollider)

## 설명

이 프로퍼티는 객체의 로컬 공간에서 측정된 구의 반지름을 나타냅니다. 반지름 값은 실수형으로 설정되며, 구체의 크기를 조정하는 데 사용됩니다.

이 프로퍼티는 읽기 및 쓰기가 가능하므로, 현재 반지름 값을 가져오거나 새로운 값을 설정할 수 있습니다. 반지름 값이 변경되면 구체의 물리적 특성이 영향을 받을 수 있으므로, 적절한 값으로 설정하는 것이 중요합니다.

## 프로퍼티 정의

- **이름**: `radius`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local radius = sphereCollider.radius
sphereCollider.radius = newRadius
```

## 참고 사항

동기화 지원
