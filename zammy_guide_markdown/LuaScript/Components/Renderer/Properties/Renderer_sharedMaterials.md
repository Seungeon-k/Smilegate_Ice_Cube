---
title: sharedMaterials
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_sharedMaterials
source_path: LuaScript/Components/Renderer/Properties/Renderer_sharedMaterials.html
last_updated: "2026.04.06 오후 02:54"
---

# sharedMaterials

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 해당 객체의 모든 공유 재질을 반환합니다. 공유 재질은 여러 렌더러가 동일한 재질을 사용할 수 있도록 하여 메모리 사용을 최적화합니다. 이 프로퍼티는 읽기 전용이며, 직접적으로 값을 설정할 수 없습니다.

이 프로퍼티를 사용할 때는 반환된 재질 배열을 수정하지 않도록 주의해야 합니다. 배열의 요소를 변경하면 모든 렌더러에 영향을 미칠 수 있습니다.

## 프로퍼티 정의

- **이름**: `sharedMaterials`
- **타입**: `Material[]`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local materials = renderer.sharedMaterials
```

## 참고 사항
