---
title: GetLayerWeight
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_GetLayerWeight_UAnimatorWrap_number
source_path: LuaScript/Components/Animator/Methods/Animator_GetLayerWeight_UAnimatorWrap_number.html
last_updated: "2026.04.06 오후 02:48"
---

# GetLayerWeight

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

지정된 인덱스의 레이어 가중치를 반환합니다. 이 함수는 레이어의 인덱스를 입력받아 해당 레이어의 가중치를 실수형으로 반환합니다. 레이어 인덱스는 0부터 시작하며, 유효한 인덱스 범위를 벗어난 경우 예외가 발생할 수 있습니다.

## 함수

GetLayerWeight(layerIndex)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `layerIndex` | 레이어의 인덱스 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| number | 레이어 가중치 |

## 예제 코드

```lua
local weight = animator:GetLayerWeight(layerIndex)
```
