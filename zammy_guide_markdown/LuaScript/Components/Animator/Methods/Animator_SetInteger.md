---
title: SetInteger
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_SetInteger
source_path: LuaScript/Components/Animator/Methods/Animator_SetInteger.html
last_updated: "2026.04.06 오후 02:48"
---

# SetInteger

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

주어진 정수 매개변수의 값을 설정합니다. 이 메서드는 두 가지 형태로 호출할 수 있으며, 매개변수 이름 또는 ID를 사용하여 값을 설정할 수 있습니다. 매개변수 이름을 사용할 경우, 해당 이름이 Animator에 정의된 정수 매개변수와 일치해야 합니다. 잘못된 이름을 사용하면 예외가 발생할 수 있습니다.

## 함수

SetInteger(propertyName, value)  
  

SetInteger(id, value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `id` | 매개변수 ID |
| `number` | `value` | 새로운 매개변수 값 |
| `string` | `propertyName` | 매개변수 이름 |

### 반환값

없음

## 예제 코드

```lua
Animator:SetInteger(name, value)
```
