---
title: GetBool
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_GetBool_UAnimatorWrap_string
source_path: LuaScript/Components/Animator/Methods/Animator_GetBool_UAnimatorWrap_string.html
last_updated: "2026.04.06 오후 02:48"
---

# GetBool

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

불리언 매개변수의 값을 가져옵니다… 이 메서드는 애니메이션 상태를 제어하는 데 사용되며, 매개변수 이름으로 값을 인수로 받습니다. 매개변수 이름은 애니메이터에서 정의된 이름과 일치해야 하며, 잘못된 이름을 사용할 경우 예외가 발생할 수 있습니다.

## 함수

GetBool(propertyName)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `propertyName` | 매개변수 이름 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 매개변수 값 |

## 예제 코드

```lua
local value = Animator:GetBool(name)
```
