---
title: CrossFade
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Methods/Animation_CrossFade
source_path: LuaScript/Components/Animation/Methods/Animation_CrossFade.html
last_updated: "2026.04.06 오후 02:47"
---

# CrossFade

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 함수는 주어진 애니메이션 이름을 사용하여 지정된 시간 동안 애니메이션을 페이드 인합니다. `fadeLength`는 애니메이션이 완전히 전환되는 데 걸리는 시간을 정의합니다. `mode` 매개변수를 사용하여 애니메이션을 중지하는 방식을 선택할 수 있습니다.

이 함수를 사용할 때는 애니메이션 이름이 정확해야 하며, 잘못된 이름을 입력할 경우 애니메이션이 재생되지 않을 수 있습니다. 또한, `fadeLength`는 양수 값이어야 하며, 음수 값이 입력될 경우 예외가 발생할 수 있습니다.

## 함수

CrossFade(animation)  
  

CrossFade(animation, fadeLength)  
  

CrossFade(animation, fadeLength, mode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `animation` | 페이드할 애니메이션의 이름입니다. |
| `number` | `fadeLength` | 애니메이션이 완전히 전환되는 데 걸리는 시간 |
| [`PlayMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/PlayMode) | `mode` | 매개변수를 사용하여 애니메이션을 중지하는 방식 |

### 반환값

없음

## 예제 코드

```lua
CrossFade(animation, fadeLength, mode)
```
