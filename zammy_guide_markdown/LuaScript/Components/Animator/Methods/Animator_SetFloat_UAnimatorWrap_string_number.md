---
title: SetFloat
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_SetFloat_UAnimatorWrap_string_number
source_path: LuaScript/Components/Animator/Methods/Animator_SetFloat_UAnimatorWrap_string_number.html
last_updated: "2026.04.06 오후 02:48"
---

# SetFloat

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 함수는 Animator에 float 값을 전송하여 전환에 영향을 미칩니다. 사용자는 애니메이션 매개변수의 이름과 새로운 값을 지정하여 애니메이션 상태를 조정할 수 있습니다. 이 함수는 매개변수 이름이 유효한지 확인하지 않으므로, 잘못된 이름을 입력할 경우 애니메이션이 예상대로 작동하지 않을 수 있습니다.

## 함수

SetFloat(propertyName, value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `propertyName` | 매개변수 이름 |
| `number` | `value` | 새로운 매개변수 값 |

### 반환값

없음

## 예제 코드

```lua
Animator.SetFloat(name, value)
```
