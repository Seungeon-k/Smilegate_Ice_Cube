---
title: IsInTransition
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_IsInTransition_UAnimatorWrap_number
source_path: LuaScript/Components/Animator/Methods/Animator_IsInTransition_UAnimatorWrap_number.html
last_updated: "2026.04.06 오후 02:48"
---

# IsInTransition

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

주어진 레이어에서 전환이 발생하고 있는지 여부를 반환합니다. 레이어 인덱스를 입력으로 받아 해당 레이어에서 전환이 진행 중이면 true를, 그렇지 않으면 false를 반환합니다. 이 메서드는 애니메이션 상태의 전환을 확인하는 데 유용합니다.

## 함수

IsInTransition(layerIndex)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `layerIndex` | 레이어 인덱스 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 레이어에서 전환이 발생하고 있는지 여부 |

## 예제 코드

```lua
local isTransitioning = Animator:IsInTransition(layerIndex)
```
