---
title: sharedMaterial
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_sharedMaterial
source_path: LuaScript/Components/Renderer/Properties/Renderer_sharedMaterial.html
last_updated: "2026.04.06 오후 02:54"
---

# sharedMaterial

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 객체의 공유 재질을 반환하거나 설정합니다. 공유 재질은 여러 객체가 동일한 재질을 사용할 수 있도록 하여 메모리 사용을 최적화합니다. 이 프로퍼티를 통해 재질을 변경하면, 해당 재질을 사용하는 모든 객체에 영향을 미칩니다.

재질을 설정할 때는 주의가 필요합니다. 만약 재질을 변경하면, 이전 재질을 사용하는 다른 객체에도 영향을 미칠 수 있습니다. 따라서, 특정 객체에만 적용할 재질이 필요하다면, 인스턴스 재질을 사용하는 것이 좋습니다.

## 프로퍼티 정의

- **이름**: `sharedMaterial`
- **타입**: `Material`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local material = renderer.sharedMaterial
renderer.sharedMaterial = newMaterial
```

## 참고 사항

동기화 지원
