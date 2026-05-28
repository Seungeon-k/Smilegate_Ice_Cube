---
title: Blend
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Methods/Animation_Blend
source_path: LuaScript/Components/Animation/Methods/Animation_Blend.html
last_updated: "2026.04.06 오후 02:47"
---

# Blend

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 함수는 지정된 애니메이션을 주어진 목표 가중치로 블렌딩합니다. 애니메이션 이름을 인수로 받아, 목표 가중치(targetWeight)와 함께 애니메이션의 블렌딩을 수행합니다.

animation: 블렌딩할 애니메이션의 이름입니다.  

targetWeight: 애니메이션의 목표 가중치입니다. 이 값에 따라 애니메이션의 강도가 조절됩니다.  

fadeLength: 애니메이션이 목표 가중치로 전환되는 시간입니다. 이 값이 클수록 부드러운 전환이 이루어집니다.  

이 함수는 애니메이션의 전환을 부드럽게 만들어 주며, 여러 애니메이션을 동시에 사용할 때 유용합니다. 사용 시 애니메이션 이름이 정확해야 하며, 잘못된 이름을 입력할 경우 애니메이션이 적용되지 않을 수 있습니다.

이 함수는 지정된 애니메이션을 주어진 목표 가중치로 블렌딩합니다. 애니메이션 이름을 인수로 받아, 목표 가중치(targetWeight)와 함께 애니메이션의 블렌딩을 수행합니다.

- `animation`: 블렌딩할 애니메이션의 이름입니다.
- `targetWeight`: 애니메이션의 목표 가중치입니다. 이 값에 따라 애니메이션의 강도가 조절됩니다.
- `fadeLength`: 애니메이션이 목표 가중치로 전환되는 시간입니다. 이 값이 클수록 부드러운 전환이 이루어집니다.

이 함수는 애니메이션의 전환을 부드럽게 만들어 주며, 여러 애니메이션을 동시에 사용할 때 유용합니다. 사용 시 애니메이션 이름이 정확해야 하며, 잘못된 이름을 입력할 경우 애니메이션이 적용되지 않을 수 있습니다.

이 함수는 지정된 애니메이션을 주어진 목표 가중치로 블렌딩합니다. 애니메이션 이름을 인수로 받아, 목표 가중치(targetWeight)와 함께 애니메이션의 블렌딩을 수행합니다. 여긴 테스트입니다.

animation: 블렌딩할 애니메이션의 이름입니다.  

targetWeight: 애니메이션의 목표 가중치입니다. 이 값에 따라 애니메이션의 강도가 조절됩니다.  

fadeLength: 애니메이션이 목표 가중치로 전환되는 시간입니다. 이 값이 클수록 부드러운 전환이 이루어집니다.  

이 함수는 애니메이션의 전환을 부드럽게 만들어 주며, 여러 애니메이션을 동시에 사용할 때 유용합니다. 사용 시 애니메이션 이름이 정확해야 하며, 잘못된 이름을 입력할 경우 애니메이션이 적용되지 않을 수 있습니다.

## 함수

Blend(animation)  
  

Blend(animation, targetWeight)  
  

Blend(animation, targetWeight, fadeLength)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `animation` | 블렌딩할 애니메이션의 이름입니다. |
| `number` | `targetWeight` | 애니메이션의 목표 가중치입니다. 이 값에 따라 애니메이션의 강도가 조절됩니다. |
| `number` | `fadeLength` | 애니메이션이 목표 가중치로 전환되는 시간입니다. 이 값이 클수록 부드러운 전환이 이루어집니다. |

### 반환값

없음

## 예제 코드

```lua
Blend(animation, targetWeight, fadeLength)
```
