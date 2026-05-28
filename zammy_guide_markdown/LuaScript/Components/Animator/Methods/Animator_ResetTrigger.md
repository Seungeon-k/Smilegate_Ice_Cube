---
title: ResetTrigger
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_ResetTrigger
source_path: LuaScript/Components/Animator/Methods/Animator_ResetTrigger.html
last_updated: "2026.04.06 오후 02:48"
---

# ResetTrigger

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

주어진 트리거 매개변수의 값을 초기화합니다. 이 메서드는 애니메이션 상태를 제어하는 데 사용되는 트리거를 리셋하는 데 유용합니다. 트리거는 애니메이션 전환을 시작하는 데 사용되는 매개변수입니다. 이 메서드를 호출하면 해당 트리거의 상태가 기본값으로 돌아갑니다.

## 함수

ResetTrigger(propertyName)  
  

ResetTrigger(id)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `id` | 매개변수 ID |
| `string` | `propertyName` | 매개변수 이름 |

### 반환값

없음

## 예제 코드

```lua
Animator:ResetTrigger(name)
```
