---
title: fillAmount
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_fillAmount
source_path: LuaScript/Components/Image/Properties/Image_fillAmount.html
last_updated: "2026.04.06 오후 02:52"
---

# fillAmount

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

`fillAmount`는 이미지의 채워진 비율을 나타내는 프로퍼티입니다. 이 값은 0.0에서 1.0 사이의 실수로, 0.0은 이미지가 전혀 채워지지 않음을, 1.0은 이미지가 완전히 채워짐을 의미합니다.

이 프로퍼티를 사용하여 UI 요소의 시각적 상태를 동적으로 조정할 수 있습니다. 예를 들어, 로딩 바나 체력 바와 같은 UI 요소에서 유용하게 사용됩니다.

값을 설정할 때는 0.0 미만이나 1.0 초과의 값을 지정하지 않도록 주의해야 합니다. 이러한 경우, 예외가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `fillAmount`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
image.fillAmount
```

## 참고 사항

동기화 미지원
