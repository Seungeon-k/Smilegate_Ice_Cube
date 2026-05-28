---
title: GetInteger
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_GetInteger
source_path: LuaScript/Components/Animator/Methods/Animator_GetInteger.html
last_updated: "2026.04.06 오후 02:48"
---

# GetInteger

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

주어진 정수 매개변수의 값을 반환합니다. 이 메서드는 매개변수의 이름 또는 ID를 사용하여 해당 값을 가져올 수 있습니다. 매개변수 이름을 사용할 경우, 해당 이름이 정확해야 하며, 존재하지 않는 경우 기본값이 반환될 수 있습니다. ID를 사용할 경우, 올바른 ID를 제공해야 합니다.

## 함수

GetInteger(propertyName)  
  

GetInteger(id)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `id` | 매개변수의 ID |
| `string` | `propertyName` | 매개변수의 이름 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| number | 정수 매개변수의 값 |

| **형식** | **설명** |
| --- | --- |
| number | 매개변수의 값 |

## 예제 코드

```lua
value = animator:GetInteger(name)
```
