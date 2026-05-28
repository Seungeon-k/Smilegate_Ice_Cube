---
title: receiveShadows
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_receiveShadows
source_path: LuaScript/Components/Renderer/Properties/Renderer_receiveShadows.html
last_updated: "2026.04.06 오후 02:54"
---

# receiveShadows

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 객체가 그림자를 받을지 여부를 결정합니다. 기본값은 false이며, true로 설정하면 해당 객체가 그림자를 받을 수 있습니다. 이 프로퍼티를 사용하여 렌더링 시 그림자 효과를 조정할 수 있습니다.

설정 시 주의할 점은, 그림자를 받는 객체는 성능에 영향을 줄 수 있으므로 필요에 따라 적절히 사용해야 합니다. 또한, 이 프로퍼티는 다른 렌더링 설정과 함께 사용될 때 최적의 결과를 보장합니다.

## 프로퍼티 정의

- **이름**: `receiveShadows`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local receiveShadows = renderer.receiveShadows
renderer.receiveShadows = true
```

## 참고 사항

동기화 지원
