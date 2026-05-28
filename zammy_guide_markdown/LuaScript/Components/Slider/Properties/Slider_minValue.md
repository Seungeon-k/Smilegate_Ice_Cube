---
title: minValue
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider/Properties/Slider_minValue
source_path: LuaScript/Components/Slider/Properties/Slider_minValue.html
last_updated: "2026.04.06 오후 02:55"
---

# minValue

## 객체

> [Slider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider)

## 설명

이 프로퍼티는 슬라이더의 최소 값을 설정하거나 가져오는 데 사용됩니다. 최소 값은 슬라이더의 현재 값이 가질 수 있는 가장 낮은 수치를 정의합니다. 이 값을 설정하면 슬라이더의 범위가 변경되므로, 슬라이더의 동작에 영향을 줄 수 있습니다.

설정할 수 있는 값은 실수형이며, 최소 값은 최대 값보다 작아야 합니다. 잘못된 값을 설정할 경우 예외가 발생할 수 있습니다. 슬라이더의 최소 값은 슬라이더의 시각적 표현에도 영향을 미치므로, 적절한 값으로 설정하는 것이 중요합니다.

## 프로퍼티 정의

- **이름**: `minValue`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local minValue = slider.minValue

slider.minValue = value
```

## 참고 사항
