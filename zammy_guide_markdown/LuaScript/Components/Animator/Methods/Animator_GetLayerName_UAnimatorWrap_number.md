---
title: GetLayerName
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_GetLayerName_UAnimatorWrap_number
source_path: LuaScript/Components/Animator/Methods/Animator_GetLayerName_UAnimatorWrap_number.html
last_updated: "2026.04.06 오후 02:48"
---

# GetLayerName

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 함수는 주어진 레이어 인덱스에 해당하는 레이어의 이름을 반환합니다. 레이어 인덱스는 0부터 시작하며, 유효한 인덱스 범위를 벗어난 경우 예외가 발생할 수 있습니다. 이 함수를 호출할 때는 반드시 유효한 레이어 인덱스를 제공해야 합니다.

## 함수

GetLayerName(layerIndex)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `layerIndex` | 레이어 인덱스 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| string | 레이어 이름 |

## 예제 코드

```lua
local layerName = Animator.GetLayerName(layerIndex)
```
