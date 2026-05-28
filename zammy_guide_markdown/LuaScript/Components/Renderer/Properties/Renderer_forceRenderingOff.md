---
title: forceRenderingOff
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_forceRenderingOff
source_path: LuaScript/Components/Renderer/Properties/Renderer_forceRenderingOff.html
last_updated: "2026.04.06 오후 02:54"
---

# forceRenderingOff

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 특정 컴포넌트의 렌더링을 끌 수 있도록 허용합니다. 이를 통해 필요하지 않은 경우 렌더링을 비활성화하여 성능을 최적화할 수 있습니다. 사용 시 주의할 점은, 렌더링이 꺼진 상태에서는 해당 컴포넌트가 화면에 표시되지 않으므로, 시각적 요소가 필요할 경우 다시 활성화해야 합니다.

## 프로퍼티 정의

- **이름**: `forceRenderingOff`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local isRenderingOff = Renderer.forceRenderingOff  -- Get
Renderer.forceRenderingOff = true  -- Set
```

## 참고 사항

동기화 지원
