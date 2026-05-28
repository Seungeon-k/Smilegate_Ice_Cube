---
title: endWidth
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer/Properties/TrailRenderer_endWidth
source_path: LuaScript/Components/TrailRenderer/Properties/TrailRenderer_endWidth.html
last_updated: "2026.04.06 오후 02:57"
---

# endWidth

## 객체

> [TrailRenderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer)

## 설명

이 프로퍼티는 트레일의 끝 부분에서의 너비를 설정하거나 가져오는 데 사용됩니다. 너비는 실수형 값으로 표현되며, 트레일의 시각적 표현에 영향을 미칩니다.

값을 설정할 때는 적절한 범위의 값을 사용해야 하며, 너무 큰 값은 예상치 못한 결과를 초래할 수 있습니다.

## 프로퍼티 정의

- **이름**: `endWidth`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local width = trailRenderer:endWidth
trailRenderer:endWidth = 2.0
```

## 참고 사항

동기화 지원
