---
title: localBounds
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_localBounds
source_path: LuaScript/Components/Renderer/Properties/Renderer_localBounds.html
last_updated: "2026.04.06 오후 02:54"
---

# localBounds

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 렌더러의 로컬 공간에서의 경계 상자를 나타냅니다. 로컬 경계는 렌더러의 변환에 따라 결정되며, 주로 물체의 크기와 위치를 정의하는 데 사용됩니다. 이 프로퍼티는 읽기 전용이며, 직접적으로 값을 설정할 수는 없습니다.

사용 시 주의할 점은, 경계 상자가 렌더러의 상태에 따라 동적으로 변경될 수 있다는 것입니다. 따라서 경계 상자를 사용할 때는 항상 최신 상태를 반영하도록 주의해야 합니다.

## 프로퍼티 정의

- **이름**: `localBounds`
- **타입**: [`Bounds`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
localBounds = renderer.localBounds
```

## 참고 사항
