---
title: endColor
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer/Properties/TrailRenderer_endColor
source_path: LuaScript/Components/TrailRenderer/Properties/TrailRenderer_endColor.html
last_updated: "2026.04.06 오후 02:57"
---

# endColor

## 객체

> [TrailRenderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer)

## 설명

이 프로퍼티는 트레일의 끝 부분에서 사용할 색상을 설정합니다. 색상은 `Color` 타입으로 반환되며, 설정할 수 있습니다. 이 프로퍼티를 사용하여 트레일의 시각적 효과를 조정할 수 있습니다.

유의사항으로는, 색상 값은 RGBA 형식으로 설정해야 하며, 잘못된 값이 입력될 경우 예외가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `endColor`
- **타입**: `Color`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
trailRenderer.endColor = Color
local color = trailRenderer.endColor
```

## 참고 사항

동기화 지원
