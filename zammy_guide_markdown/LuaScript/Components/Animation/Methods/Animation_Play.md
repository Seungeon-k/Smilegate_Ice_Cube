---
title: Play
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Methods/Animation_Play
source_path: LuaScript/Components/Animation/Methods/Animation_Play.html
last_updated: "2026.04.06 오후 02:47"
---

# Play

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 메서드는 애니메이션을 블렌딩 없이 재생합니다. 애니메이션 이름이 제공되지 않거나 기본 애니메이션이 없으면 false를 반환하고, 그렇지 않으면 true를 반환합니다.

애니메이션을 재생할 때, mode 매개변수를 통해 애니메이션의 중지 방식을 선택할 수 있습니다. 기본적으로 동일 레이어에서 시작된 애니메이션을 중지하는 StopSameLayer가 사용됩니다. 필요에 따라 StopAll을 선택하여 모든 애니메이션을 중지할 수 있습니다.

## 함수

Play()  
  

Play(animation)  
  

Play(animation, mode)  
  

Play(mode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`PlayMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/PlayMode) | `mode` | 애니메이션의 중지 방식을 선택 애니메이션의 중지 방식 |
| `string` | `animation` | 애니메이션 이름 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 애니메이션 이름이 제공되지 않거나 기본 애니메이션이 없으면 false를 반환하고, 그렇지 않으면 true를 반환 |

| **형식** | **설명** |
| --- | --- |
| boolean | 애니메이션 이름이 제공되지 않거나 기본 애니메이션이 없으면 false를 반환하고, 그렇지 않으면 true를 반환 |

## 예제 코드

```lua
result = Animation:Play(animation, mode)
```
