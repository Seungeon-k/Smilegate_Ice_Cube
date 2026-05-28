---
title: SetValueWithoutNotify
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider/Methods/Slider_SetValueWithoutNotify_USliderWrap_number
source_path: LuaScript/Components/Slider/Methods/Slider_SetValueWithoutNotify_USliderWrap_number.html
last_updated: "2026.04.06 오후 02:55"
---

# SetValueWithoutNotify

## 객체

> [Slider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider)

## 설명

이 함수는 슬라이더의 값을 변경하지만, 값 변경에 대한 알림을 발생시키지 않습니다. 주로 슬라이더의 값을 프로그래밍적으로 설정할 때 사용됩니다. 이 메서드를 호출하면 슬라이더의 UI가 업데이트되지 않으므로, 값 변경에 따른 이벤트를 수신할 필요가 없는 경우에 유용합니다.

## 함수

SetValueWithoutNotify(input)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `input` | 슬라이더에 설정할 값 |

### 반환값

없음

## 예제 코드

```lua
Slider:SetValueWithoutNotify(input)
```
