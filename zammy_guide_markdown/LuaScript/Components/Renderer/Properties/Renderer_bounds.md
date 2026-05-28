---
title: bounds
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_bounds
source_path: LuaScript/Components/Renderer/Properties/Renderer_bounds.html
last_updated: "2026.04.06 오후 02:54"
---

# bounds

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 렌더러의 월드 공간에서의 경계 상자를 반환합니다. 경계 상자는 렌더러가 차지하는 공간을 정의하며, 주로 충돌 감지나 시각적 표시를 위해 사용됩니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다.

## 프로퍼티 정의

- **이름**: `bounds`
- **타입**: [`Bounds`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local bounds = renderer.bounds
```

## 참고 사항
