---
title: widthMultiplier
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer/Properties/TrailRenderer_widthMultiplier
source_path: LuaScript/Components/TrailRenderer/Properties/TrailRenderer_widthMultiplier.html
last_updated: "2026.04.06 오후 02:57"
---

# widthMultiplier

## 객체

> [TrailRenderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer)

## 설명

이 프로퍼티는 TrailRenderer.widthCurve에 적용되는 전체 배율을 설정하여 트레일의 최종 너비를 결정합니다. 이 값을 조정함으로써 트레일의 시각적 효과를 쉽게 변경할 수 있습니다.

값은 실수형(Single)으로 설정되며, 0보다 큰 값을 사용하는 것이 일반적입니다. 0 이하의 값은 예기치 않은 결과를 초래할 수 있으므로 주의해야 합니다.

## 프로퍼티 정의

- **이름**: `widthMultiplier`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local widthMultiplier = trailRenderer.widthMultiplier
trailRenderer.widthMultiplier = newValue
```

## 참고 사항

동기화 지원
