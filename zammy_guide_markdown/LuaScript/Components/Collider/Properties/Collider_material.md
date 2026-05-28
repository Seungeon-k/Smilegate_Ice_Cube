---
title: material
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Properties/Collider_material
source_path: LuaScript/Components/Collider/Properties/Collider_material.html
last_updated: "2026.04.06 오후 02:51"
---

# material

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 프로퍼티는 콜라이더에서 사용되는 물리 재질을 나타냅니다. 물리 재질은 충돌 시의 물리적 특성을 정의하며, 이를 통해 다양한 물리적 상호작용을 설정할 수 있습니다.

이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 코드에서 물리 재질을 동적으로 변경할 수 있습니다. 물리 재질을 설정할 때는 유효한 `PhysicMaterial` 객체를 사용해야 하며, 잘못된 객체를 설정할 경우 예외가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `material`
- **타입**: `PhysicMaterial`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
collider.material
```

## 참고 사항

동기화 지원
