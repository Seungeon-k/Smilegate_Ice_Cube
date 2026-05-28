---
title: radius
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_radius
source_path: LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_radius.html
last_updated: "2026.04.06 오후 02:51"
---

# radius

## 객체

> [CapsuleCollider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/CapsuleCollider)

## 설명

이 프로퍼티는 객체의 로컬 공간에서 측정된 구의 반지름을 나타냅니다. 반지름 값은 실수형으로 설정되며, 객체의 물리적 특성에 영향을 미칩니다.

이 프로퍼티를 사용할 때는 반지름 값이 너무 작거나 클 경우 물리적 상호작용에 예상치 못한 결과를 초래할 수 있으므로 주의해야 합니다.

## 프로퍼티 정의

- **이름**: `radius`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local radius = capsuleCollider.radius
capsuleCollider.radius = newRadius
```

## 참고 사항

동기화 지원
