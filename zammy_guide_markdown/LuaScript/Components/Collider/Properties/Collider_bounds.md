---
title: bounds
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Properties/Collider_bounds
source_path: LuaScript/Components/Collider/Properties/Collider_bounds.html
last_updated: "2026.04.06 오후 02:51"
---

# bounds

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 프로퍼티는 충돌체의 월드 스페이스 경계 볼륨을 반환합니다. 이 값은 읽기 전용이며, 충돌체의 크기와 위치를 나타냅니다. 사용 시 주의할 점은 이 프로퍼티를 통해 값을 설정할 수 없다는 것입니다. 또한, 이 프로퍼티는 충돌체가 활성화되어 있을 때만 유효합니다.

## 프로퍼티 정의

- **이름**: `bounds`
- **타입**: [`Bounds`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local bounds = collider.bounds
```

## 참고 사항

동기화 미지원
