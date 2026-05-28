---
title: TransformPoint
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_TransformPoint
source_path: LuaScript/Components/Transform/Methods/Transform_TransformPoint.html
last_updated: "2026.04.06 오후 02:57"
---

# TransformPoint

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 함수는 로컬 공간의 위치를 월드 공간으로 변환합니다. 주어진 위치 벡터를 사용하여 해당 위치의 월드 좌표를 계산합니다. 이 메서드는 주로 객체의 위치를 다른 좌표계로 변환할 때 사용됩니다.

이 함수는 로컬 공간의 위치를 월드 공간으로 변환합니다. 주어진 x, y, z 좌표를 사용하여 변환된 위치를 반환합니다. 이 메서드는 3D 공간에서 객체의 위치를 조정할 때 유용합니다. 사용 시 주의할 점은 입력 값이 로컬 공간의 좌표여야 하며, 변환된 결과는 월드 공간의 좌표로 반환된다는 것입니다.

## 함수

TransformPoint(position)  
  

TransformPoint(x, y, z)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `position` | 변환할 로컬 공간의 위치 |
| `number` | `x` | x 좌표 |
| `number` | `y` | y 좌표 |
| `number` | `z` | z 좌표 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환 된 결과 |

## 예제 코드

```lua
local worldPosition = transform:TransformPoint(position)
```
