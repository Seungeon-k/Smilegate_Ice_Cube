---
title: TransformDirection
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_TransformDirection
source_path: LuaScript/Components/Transform/Methods/Transform_TransformDirection.html
last_updated: "2026.04.06 오후 02:57"
---

# TransformDirection

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 함수는 로컬 공간에서 월드 공간으로 방향을 변환합니다. 주어진 방향 벡터를 로컬 좌표계에서 월드 좌표계로 변환하여 반환합니다. 이 메서드는 주로 물체의 방향을 계산할 때 유용하게 사용됩니다.

이 함수는 로컬 공간에서 월드 공간으로 방향을 변환합니다. 주어진 x, y, z 좌표를 사용하여 변환된 방향 벡터를 반환합니다. 이 메서드는 주로 객체의 방향을 계산할 때 유용하게 사용됩니다.

## 함수

TransformDirection(direction)  
  

TransformDirection(x, y, z)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `direction` | 변환할 방향 벡터 |
| `number` | `x` | x 좌표 |
| `number` | `y` | y 좌표 |
| `number` | `z` | z 좌표 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환된 방향 벡터 |

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환 된 결과 |

## 예제 코드

```lua
local result = Transform:TransformDirection(direction)
```
