---
title: startWidth
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer/Properties/TrailRenderer_startWidth
source_path: LuaScript/Components/TrailRenderer/Properties/TrailRenderer_startWidth.html
last_updated: "2026.04.06 오후 02:57"
---

# startWidth

## 객체

> [TrailRenderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer)

## 설명

이 프로퍼티는 트레일의 시작 지점에서의 너비를 설정하거나 가져오는 데 사용됩니다. 너비는 실수형 값으로 표현되며, 트레일의 시각적 효과에 영향을 미칩니다.

값을 설정할 때는 적절한 범위의 값을 사용해야 하며, 너무 작은 값은 트레일이 보이지 않게 만들 수 있습니다.

## 프로퍼티 정의

- **이름**: `startWidth`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local width = trailRenderer.startWidth
trailRenderer.startWidth = 2.0
```

## 참고 사항

동기화 지원
