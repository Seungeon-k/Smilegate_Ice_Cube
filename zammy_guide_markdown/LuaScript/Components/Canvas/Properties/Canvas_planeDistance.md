---
title: planeDistance
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas/Properties/Canvas_planeDistance
source_path: LuaScript/Components/Canvas/Properties/Canvas_planeDistance.html
last_updated: "2026.04.06 오후 02:51"
---

# planeDistance

## 객체

> [Canvas](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas)

## 설명

`planeDistance`는 [`Canvas`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas)가 Screen Space - Camera 모드일 때, UI가 그려지는 캔버스 평면이 카메라로부터 떨어진 거리를 나타내는 읽기 전용 프로퍼티입니다.  

이 값은 렌더링/입력 좌표 변환에서 “UI 평면 위치”를 결정하는 데 영향을 줍니다.

## 프로퍼티 정의

- **이름**: `planeDistance`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.planeDistance
    this.scriptObject:Log(tostring(value))
end
```
