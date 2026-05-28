---
title: material
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_material
source_path: LuaScript/Components/Renderer/Properties/Renderer_material.html
last_updated: "2026.04.06 오후 02:54"
---

# material

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 렌더러에 할당된 첫 번째 인스턴스화된 머티리얼을 반환합니다. 머티리얼을 읽거나 설정할 수 있으며, 이를 통해 렌더링에 사용되는 머티리얼을 동적으로 변경할 수 있습니다. 사용 시 주의할 점은 머티리얼을 변경하면 해당 렌더러에 영향을 미치므로, 필요에 따라 적절한 머티리얼을 설정해야 합니다.

## 프로퍼티 정의

- **이름**: `material`
- **타입**: `Material`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local material = renderer.material
renderer.material = newMaterial
```

## 참고 사항

동기화 지원
