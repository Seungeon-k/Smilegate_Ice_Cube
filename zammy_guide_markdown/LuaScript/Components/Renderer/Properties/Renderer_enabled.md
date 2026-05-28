---
title: enabled
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_enabled
source_path: LuaScript/Components/Renderer/Properties/Renderer_enabled.html
last_updated: "2026.04.06 오후 02:54"
---

# enabled

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 렌더링된 3D 객체를 활성화할 수 있게 해줍니다. 활성화된 경우 객체는 화면에 표시됩니다. 비활성화되면 객체는 보이지 않게 됩니다. 이 프로퍼티는 읽기 및 쓰기가 가능하며, 객체의 가시성을 제어하는 데 유용합니다.

## 프로퍼티 정의

- **이름**: `enabled`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local isEnabled = renderer.enabled  -- Get
renderer.enabled = true  -- Set
```

## 참고 사항

동기화 지원
