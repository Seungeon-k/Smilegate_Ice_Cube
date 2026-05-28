---
title: sharedMaterial
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Properties/Collider_sharedMaterial
source_path: LuaScript/Components/Collider/Properties/Collider_sharedMaterial.html
last_updated: "2026.04.06 오후 02:51"
---

# sharedMaterial

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 프로퍼티는 해당 충돌체의 공유 물리 재질을 반환하거나 설정합니다. 물리 재질은 충돌체의 물리적 특성을 정의하며, 여러 충돌체가 동일한 물리 재질을 공유할 수 있습니다. 이 프로퍼티를 사용하여 충돌체의 물리적 상호작용을 조정할 수 있습니다.

프로퍼티에 접근할 때는 주의가 필요합니다. 물리 재질을 변경하면 해당 충돌체의 물리적 특성이 즉시 반영됩니다. 또한, 여러 충돌체가 동일한 물리 재질을 참조할 경우, 하나의 충돌체에서 물리 재질을 변경하면 다른 충돌체에도 영향을 미칠 수 있습니다.

## 프로퍼티 정의

- **이름**: `sharedMaterial`
- **타입**: `PhysicMaterial`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
collider.sharedMaterial
```

## 참고 사항

동기화 지원
