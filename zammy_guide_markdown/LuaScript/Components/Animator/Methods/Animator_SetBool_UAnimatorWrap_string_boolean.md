---
title: SetBool
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_SetBool_UAnimatorWrap_string_boolean
source_path: LuaScript/Components/Animator/Methods/Animator_SetBool_UAnimatorWrap_string_boolean.html
last_updated: "2026.04.06 오후 02:48"
---

# SetBool

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

주어진 불리언 매개변수의 값을 설정합니다. 이 메서드는 애니메이션 상태를 제어하는 데 사용되며, 매개변수 이름과 새로운 값을 인수로 받습니다. 매개변수 이름은 애니메이터에서 정의된 이름과 일치해야 하며, 잘못된 이름을 사용할 경우 예외가 발생할 수 있습니다.

## 함수

SetBool(propertyName, value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `propertyName` | 매개변수 이름 |
| `boolean` | `value` | 새로운 매개변수 값 |

### 반환값

없음

## 예제 코드

```lua
Animator:SetBool(name, value)
```
