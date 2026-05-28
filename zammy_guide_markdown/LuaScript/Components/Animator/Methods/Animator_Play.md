---
title: Play
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_Play
source_path: LuaScript/Components/Animator/Methods/Animator_Play.html
last_updated: "2026.04.06 오후 02:48"
---

# Play

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 함수는 지정된 상태를 재생합니다. `stateName` 또는 `stateNameHash`를 사용하여 재생할 상태를 지정할 수 있으며, `layer`를 통해 특정 레이어에서 재생할 수 있습니다. `normalizedTime`을 사용하면 재생할 상태의 시간 오프셋을 설정할 수 있습니다.

`layer`가 -1로 설정되면 주어진 상태 이름이나 해시를 가진 첫 번째 상태가 재생됩니다. 이 함수는 여러 오버로드를 제공하므로 필요에 따라 적절한 형태를 선택하여 사용할 수 있습니다.

## 함수

Play(stateName)  
  

Play(stateName, layer)  
  

Play(stateName, layer, normalizedTime)  
  

Play(stateNameHash)  
  

Play(stateNameHash, layer)  
  

Play(stateNameHash, layer, normalizedTime)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `stateNameHash` | 상태 해시 |
| `number` | `layer` | 특정 레이어 |
| `number` | `normalizedTime` | 재생할 상태의 시간 오프셋 |
| `string` | `stateName` | 상태 이름 |

### 반환값

없음

## 예제 코드

```lua
Animator:Play(stateNameHash, layer, normalizedTime)
```
