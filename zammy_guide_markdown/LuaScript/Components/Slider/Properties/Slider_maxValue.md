---
title: maxValue
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider/Properties/Slider_maxValue
source_path: LuaScript/Components/Slider/Properties/Slider_maxValue.html
last_updated: "2026.04.06 오후 02:55"
---

# maxValue

## 객체

> [Slider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider)

## 설명

이 프로퍼티는 슬라이더의 최대 값을 설정하거나 가져오는 데 사용됩니다. 최대 값은 슬라이더가 가질 수 있는 가장 큰 수치를 정의합니다. 이 값을 설정하면 슬라이더의 범위가 변경되며, 슬라이더의 현재 값은 이 최대 값 이하로 설정되어야 합니다.

슬라이더의 최대 값을 설정할 때는 유효한 수치로 지정해야 하며, 음수나 비정상적인 값은 예외를 발생시킬 수 있습니다. 또한, 슬라이더의 최소 값보다 작거나 같은 값으로 설정할 수 없습니다.

## 프로퍼티 정의

- **이름**: `maxValue`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local maxValue = slider.maxValue
slider.maxValue = maxValue
```

## 참고 사항
