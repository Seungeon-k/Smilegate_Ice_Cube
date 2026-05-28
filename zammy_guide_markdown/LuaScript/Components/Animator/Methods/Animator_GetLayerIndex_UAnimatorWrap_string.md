---
title: GetLayerIndex
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_GetLayerIndex_UAnimatorWrap_string
source_path: LuaScript/Components/Animator/Methods/Animator_GetLayerIndex_UAnimatorWrap_string.html
last_updated: "2026.04.06 오후 02:48"
---

# GetLayerIndex

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 함수는 주어진 이름을 가진 레이어의 인덱스를 반환합니다. 레이어 이름은 문자열 형식으로 입력해야 하며, 해당 레이어가 존재하지 않을 경우 반환값은 정의되지 않습니다. 사용 시 레이어 이름이 정확한지 확인하는 것이 중요합니다.

## 함수

GetLayerIndex(layerName)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `layerName` | 레이어 이름 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| number | 레이어 인덱스 |

## 예제 코드

```lua
index = Animator.GetLayerIndex(layerName)
```
