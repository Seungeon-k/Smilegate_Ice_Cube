---
title: IsParameterControlledByCurve
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_IsParameterControlledByCurve
source_path: LuaScript/Components/Animator/Methods/Animator_IsParameterControlledByCurve.html
last_updated: "2026.04.06 오후 02:48"
---

# IsParameterControlledByCurve

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 함수는 주어진 파라미터가 곡선에 의해 제어되는지 여부를 반환합니다. 파라미터 이름 또는 ID를 사용하여 호출할 수 있으며, 곡선에 의해 제어되는 경우 true를 반환하고, 그렇지 않은 경우 false를 반환합니다.

## 함수

IsParameterControlledByCurve(name)  
  

IsParameterControlledByCurve(id)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `id` | 파라미터 ID |
| `string` | `name` | 파라미터 이름 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 파라미터가 곡선에 의해 제어되는지 여부 |

## 예제 코드

```lua
result = Animator:IsParameterControlledByCurve(name)
```
