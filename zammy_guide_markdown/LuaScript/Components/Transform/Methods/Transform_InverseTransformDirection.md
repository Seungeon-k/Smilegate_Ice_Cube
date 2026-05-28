---
title: InverseTransformDirection
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_InverseTransformDirection
source_path: LuaScript/Components/Transform/Methods/Transform_InverseTransformDirection.html
last_updated: "2026.04.06 오후 02:57"
---

# InverseTransformDirection

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 함수는 월드 공간에서 로컬 공간으로 방향을 변환합니다. 이는 `Transform.TransformDirection`의 반대 작업입니다. 주의할 점은 입력으로 제공되는 방향 벡터가 월드 공간에서의 방향이어야 하며, 반환되는 벡터는 로컬 공간에서의 방향입니다. 이 함수는 주로 객체의 로컬 좌표계에서 방향을 계산할 때 유용합니다.

이 함수는 월드 공간에서 로컬 공간으로 방향을 변환합니다. 이는 `Transform.TransformDirection`의 반대 작업입니다. 사용 시 주의할 점은 입력 값이 올바른 방향을 나타내야 하며, 변환된 결과는 로컬 공간에서의 방향을 나타냅니다.

## 함수

InverseTransformDirection(direction)  
  

InverseTransformDirection(x, y, z)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `direction` | 변환할 방향 벡터 |
| `number` | `x` | x 좌표 방향 |
| `number` | `y` | y 좌표 방향 |
| `number` | `z` | z 좌표 방향 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환된 결과 |

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환 된 결과 |

## 예제 코드

```lua
local localDirection = transform:InverseTransformDirection(worldDirection)
```
