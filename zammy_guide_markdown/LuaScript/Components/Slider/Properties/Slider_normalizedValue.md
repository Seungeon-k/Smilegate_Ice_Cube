---
title: normalizedValue
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider/Properties/Slider_normalizedValue
source_path: LuaScript/Components/Slider/Properties/Slider_normalizedValue.html
last_updated: "2026.04.06 오후 02:55"
---

# normalizedValue

## 객체

> [Slider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider)

## 설명

이 프로퍼티는 슬라이더의 현재 값을 0과 1 사이의 비율로 나타냅니다. 슬라이더의 위치를 정규화된 값으로 표현하여, UI에서의 비율을 쉽게 조정할 수 있습니다.

슬라이더의 값이 변경될 때마다 이 프로퍼티를 통해 현재 값을 읽거나 설정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `normalizedValue`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local value = slider.normalizedValue
slider.normalizedValue = value
```

## 참고 사항
