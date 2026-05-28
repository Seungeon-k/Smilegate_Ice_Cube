---
title: time
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer/Properties/TrailRenderer_time
source_path: LuaScript/Components/TrailRenderer/Properties/TrailRenderer_time.html
last_updated: "2026.04.06 오후 02:57"
---

# time

## 객체

> [TrailRenderer](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TrailRenderer)

## 설명

이 프로퍼티는 트레일이 사라지는 데 걸리는 시간을 설정하거나 가져오는 데 사용됩니다. 이 값을 조정하여 트레일의 지속 시간을 제어할 수 있습니다.

트레일의 사라짐 시간은 실수형으로 표현되며, 기본값은 0.5초입니다. 이 값을 너무 작게 설정하면 트레일이 너무 빨리 사라질 수 있으며, 너무 크게 설정하면 트레일이 너무 오랫동안 남아있을 수 있습니다.

예외 케이스는 없지만, 이 프로퍼티를 설정하기 전에 트레일 렌더러가 활성화되어 있어야 합니다.

## 프로퍼티 정의

- **이름**: `time`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local time = trailRenderer.time
trailRenderer.time = 1.0
```

## 참고 사항

동기화 지원
