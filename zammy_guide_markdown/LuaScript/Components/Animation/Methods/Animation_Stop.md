---
title: Stop
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Methods/Animation_Stop
source_path: LuaScript/Components/Animation/Methods/Animation_Stop.html
last_updated: "2026.04.06 오후 02:47"
---

# Stop

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 함수는 현재 재생 중인 모든 애니메이션을 중지합니다. `Stop` 함수는 두 가지 형태로 호출할 수 있습니다. 첫 번째 형태는 인수 없이 호출하여 모든 애니메이션을 중지하며, 두 번째 형태는 특정 이름을 가진 애니메이션만 중지합니다.

이 함수를 사용할 때는 애니메이션이 이미 중지된 상태에서 다시 호출해도 오류가 발생하지 않으므로, 안전하게 사용할 수 있습니다.

## 함수

Stop()  
  

Stop(name)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `name` | 중지할 애니메이션 이름 |

### 반환값

없음

## 예제 코드

```lua
Animation:Stop(name)
```
