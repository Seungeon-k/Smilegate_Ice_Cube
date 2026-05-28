---
title: GetNextAnimatorStateInfo
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_GetNextAnimatorStateInfo_UAnimatorWrap_number
source_path: LuaScript/Components/Animator/Methods/Animator_GetNextAnimatorStateInfo_UAnimatorWrap_number.html
last_updated: "2026.04.06 오후 02:48"
---

# GetNextAnimatorStateInfo

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 함수는 다음 상태에 대한 정보를 포함하는 [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)를 반환합니다. 주어진 레이어 인덱스에 해당하는 애니메이션 상태 정보를 가져오는 데 사용됩니다. 레이어 인덱스는 0부터 시작하며, 유효한 인덱스 범위를 벗어날 경우 예외가 발생할 수 있습니다.

## 함수

GetNextAnimatorStateInfo(layerIndex)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `layerIndex` | 레이어 인덱스 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo) | 상태에 대한 정보 |

## 예제 코드

```lua
local stateInfo = animator:GetNextAnimatorStateInfo(layerIndex)
```
