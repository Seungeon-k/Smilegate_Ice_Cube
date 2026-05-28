---
title: value
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider/Properties/Slider_value
source_path: LuaScript/Components/Slider/Properties/Slider_value.html
last_updated: "2026.04.06 오후 02:55"
---

# value

## 객체

> [Slider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider)

## 설명

이 프로퍼티는 슬라이더의 현재 값을 나타냅니다. 값은 실수형(Single)으로 표현되며, 슬라이더의 위치에 따라 변경됩니다. 사용자는 이 값을 읽거나 설정할 수 있습니다.

슬라이더의 값은 일반적으로 0에서 1 사이의 범위를 가지며, 특정 상황에서는 이 범위를 벗어날 수 있습니다. 따라서 값을 설정할 때는 유효한 범위 내에 있는지 확인하는 것이 좋습니다.

예외 케이스로는 슬라이더가 비활성화된 상태에서 값을 설정하려고 할 경우, 값이 적용되지 않을 수 있습니다.

## 프로퍼티 정의

- **이름**: `value`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local value = slider.value
```

## 참고 사항
