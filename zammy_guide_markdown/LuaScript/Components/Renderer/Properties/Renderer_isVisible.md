---
title: isVisible
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer/Properties/Renderer_isVisible
source_path: LuaScript/Components/Renderer/Properties/Renderer_isVisible.html
last_updated: "2026.04.06 오후 02:54"
---

# isVisible

## 객체

> [Renderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Renderer)

## 설명

이 프로퍼티는 렌더러가 어떤 카메라에서도 보이는지를 나타냅니다. 읽기 전용이며, 렌더러가 현재 화면에 표시되고 있는지를 확인하는 데 사용됩니다. 이 값을 통해 렌더링 상태를 판단할 수 있습니다.

렌더러가 비활성화되거나 카메라의 시야에 포함되지 않는 경우, 이 프로퍼티는 false를 반환합니다. 이 프로퍼티는 쓰기 가능한 속성이 아니므로 값을 설정할 수 없습니다.

## 프로퍼티 정의

- **이름**: `isVisible`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isVisible = renderer.isVisible
```

## 참고 사항
