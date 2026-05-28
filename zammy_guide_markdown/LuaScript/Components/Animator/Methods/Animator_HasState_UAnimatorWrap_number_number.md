---
title: HasState
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_HasState_UAnimatorWrap_number_number
source_path: LuaScript/Components/Animator/Methods/Animator_HasState_UAnimatorWrap_number_number.html
last_updated: "2026.04.06 오후 02:48"
---

# HasState

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 함수는 지정된 레이어에 해당 상태가 존재하는지 여부를 반환합니다. 레이어 인덱스와 상태 ID를 인수로 받아, 해당 상태가 존재하면 true를, 그렇지 않으면 false를 반환합니다. 이 함수는 애니메이션 상태를 확인할 때 유용하게 사용됩니다.

## 함수

HasState(layerIndex, stateID)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `layerIndex` | 레이어 인덱스 |
| `number` | `stateID` | 상태 ID |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 상태가 존재하면 true를, 그렇지 않으면 false |

## 예제 코드

```lua
local exists = Animator:HasState(layerIndex, stateID)
```
