---
title: materials
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_materials
source_path: LuaScript/Components/Renderer/Properties/Renderer_materials.html
last_updated: "2026.04.06 오후 02:54"
---

# materials

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 해당 객체의 모든 인스턴스화된 재질(Material)을 반환합니다. 재질은 렌더링에 사용되는 표면의 특성을 정의하며, 이 프로퍼티를 통해 현재 객체에 적용된 모든 재질을 확인할 수 있습니다.

재질을 수정할 수는 없으며, 읽기 전용으로 제공됩니다. 이 프로퍼티를 사용할 때는 반환된 재질 배열을 통해 각 재질의 속성을 확인하거나 조작할 수 있습니다. 그러나 재질을 직접 변경하는 것은 불가능하므로, 필요한 경우 새로운 재질을 생성하여 적용해야 합니다.

## 프로퍼티 정의

- **이름**: `materials`
- **타입**: `Material[]`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local materials = renderer.materials
```

## 참고 사항
