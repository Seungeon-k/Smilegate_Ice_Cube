---
title: wholeNumbers
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider/Properties/Slider_wholeNumbers
source_path: LuaScript/Components/Slider/Properties/Slider_wholeNumbers.html
last_updated: "2026.04.06 오후 02:55"
---

# wholeNumbers

## 객체

> [Slider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Slider)

## 설명

이 프로퍼티는 슬라이더가 정수 값만을 허용할지 여부를 결정합니다. `true`로 설정하면 슬라이더는 정수 값만을 사용하고, `false`로 설정하면 실수 값도 허용됩니다.  

슬라이더의 동작 방식에 따라 이 프로퍼티를 적절히 설정해야 합니다. 예를 들어, 정수 값만을 필요로 하는 경우 이 프로퍼티를 `true`로 설정해야 합니다.  

이 프로퍼티는 읽기 및 쓰기가 가능하며, 슬라이더의 값이 변경될 때마다 이 설정이 반영됩니다.

## 프로퍼티 정의

- **이름**: `wholeNumbers`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
wholeNumbers = slider.wholeNumbers
```

## 참고 사항
