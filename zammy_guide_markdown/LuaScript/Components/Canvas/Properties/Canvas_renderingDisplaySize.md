---
title: renderingDisplaySize
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas/Properties/Canvas_renderingDisplaySize
source_path: LuaScript/Components/Canvas/Properties/Canvas_renderingDisplaySize.html
last_updated: "2026.04.06 오후 02:51"
---

# renderingDisplaySize

## 객체

> [Canvas](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas)

## 설명

이 프로퍼티는 선택된 렌더 모드와 타겟 디스플레이에 기반하여 캔버스의 디스플레이 크기를 반환합니다. 이 값은 읽기 전용이며, 설정할 수 없습니다. 사용 시 주의할 점은 이 프로퍼티가 동기화를 지원하지 않으므로, 멀티스레드 환경에서의 사용은 피해야 합니다.

## 프로퍼티 정의

- **이름**: `renderingDisplaySize`
- **타입**: [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local displaySize = Canvas.renderingDisplaySize
```

## 참고 사항
