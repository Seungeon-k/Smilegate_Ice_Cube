---
title: InverseTransformPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_InverseTransformPoint
source_path: LuaScript/Components/Transform/Methods/Transform_InverseTransformPoint.html
last_updated: "2026.04.06 오후 02:57"
---

# InverseTransformPoint

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 함수는 월드 공간의 위치를 로컬 공간으로 변환합니다. 주어진 위치를 기준으로 해당 위치의 로컬 좌표계를 반환합니다. 이 함수는 주로 객체의 위치를 변환할 때 사용됩니다. 사용 시 주의할 점은 입력된 위치가 올바른 형식이어야 하며, 변환 결과는 해당 객체의 로컬 공간에 따라 달라질 수 있습니다.

이 함수는 월드 공간의 위치를 로컬 공간으로 변환합니다. 주어진 x, y, z 좌표를 사용하여 해당 위치를 변환한 결과를 반환합니다. 이 메서드는 주로 객체의 위치를 다른 좌표계로 변환할 때 사용됩니다.

## 함수

InverseTransformPoint(position)  
  

InverseTransformPoint(x, y, z)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `position` | 변환할 월드 공간의 위치 |
| `number` | `x` | x 좌표 위치 |
| `number` | `y` | y 좌표 위치 |
| `number` | `z` | z 좌표 위치 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환된 결과 |

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환 된 결과 |

## 예제 코드

```lua
local localPosition = Transform:InverseTransformPoint(worldPosition)
```
