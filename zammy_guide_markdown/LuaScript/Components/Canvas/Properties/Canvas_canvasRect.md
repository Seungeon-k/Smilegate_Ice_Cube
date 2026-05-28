---
title: canvasRect
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas/Properties/Canvas_canvasRect
source_path: LuaScript/Components/Canvas/Properties/Canvas_canvasRect.html
last_updated: "2026.04.06 오후 02:51"
---

# canvasRect

## 객체

> [Canvas](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas)

## 설명

`canvasRect`는 [`Canvas`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas)의 RectTransform.rect(로컬 좌표 기준의 사각 영역)를 반환하는 읽기 전용 프로퍼티입니다.  

Canvas.transform이 RectTransform이 아니면 예외가 발생하므로, UI 오브젝트에서만 사용해야 합니다.

## 프로퍼티 정의

- **이름**: `canvasRect`
- **타입**: [`Rect`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Rect)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.canvasRect
    this.scriptObject:Log(tostring(value))
end
```
