---
title: Rewind
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Methods/Animation_Rewind
source_path: LuaScript/Components/Animation/Methods/Animation_Rewind.html
last_updated: "2026.04.06 오후 02:47"
---

# Rewind

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 함수는 지정된 애니메이션을 처음 상태로 되돌립니다. `name` 매개변수를 사용하여 특정 애니메이션을 지정할 수 있습니다.

첫 번째 호출은 애니메이션의 이름을 지정하지 않고 모든 애니메이션을 되돌립니다. 두 번째 호출은 특정 애니메이션의 이름을 통해 해당 애니메이션만 되돌립니다.

이 함수는 애니메이션이 재생 중일 때도 호출할 수 있으며, 애니메이션의 상태를 초기화합니다. 주의할 점은 애니메이션 이름이 잘못되었거나 존재하지 않을 경우 아무런 동작도 수행하지 않는다는 것입니다.

## 함수

Rewind()  
  

Rewind(name)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `name` | 애니메이션의 이름 |

### 반환값

없음

## 예제 코드

```lua
Animation:Rewind(name)
```
