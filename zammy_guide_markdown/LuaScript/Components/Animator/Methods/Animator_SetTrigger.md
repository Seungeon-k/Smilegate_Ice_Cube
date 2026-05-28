---
title: SetTrigger
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_SetTrigger
source_path: LuaScript/Components/Animator/Methods/Animator_SetTrigger.html
last_updated: "2026.04.06 오후 02:48"
---

# SetTrigger

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 함수는 주어진 트리거 매개변수의 값을 설정합니다. 트리거는 애니메이션 전환을 제어하는 데 사용됩니다. 이 메서드는 두 가지 형태로 호출할 수 있으며, 문자열 이름 또는 정수 ID를 인수로 받을 수 있습니다. 주의할 점은 트리거 이름이 정확해야 하며, 잘못된 이름을 입력할 경우 애니메이션이 예상대로 작동하지 않을 수 있습니다.

## 함수

SetTrigger(propertyName)  
  

SetTrigger(id)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `id` | 매개변수 ID |
| `string` | `propertyName` | 매개변수 이름 |

### 반환값

없음

## 예제 코드

```lua
Animator.SetTrigger(name)
```
