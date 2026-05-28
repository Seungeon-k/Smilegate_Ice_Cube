---
title: TransformVector
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_TransformVector
source_path: LuaScript/Components/Transform/Methods/Transform_TransformVector.html
last_updated: "2026.04.06 오후 02:57"
---

# TransformVector

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 함수는 로컬 공간의 벡터를 월드 공간으로 변환합니다. 주어진 벡터는 로컬 좌표계에서의 위치를 나타내며, 이 함수를 호출하면 해당 벡터가 월드 좌표계로 변환됩니다. 이 메서드는 벡터의 방향과 크기를 고려하여 변환을 수행합니다. 사용 시 주의할 점은 입력 벡터가 올바른 형식이어야 하며, 변환 결과는 원본 벡터와 다를 수 있습니다.

이 함수는 로컬 공간에서 월드 공간으로 벡터를 변환합니다. 주어진 x, y, z 좌표를 사용하여 변환된 벡터를 반환합니다. 이 메서드는 벡터의 방향과 크기를 변경하는 데 유용합니다. 사용 시 주의할 점은 입력 값이 올바른 범위 내에 있어야 하며, 변환된 결과는 월드 공간에서의 위치를 나타냅니다.

## 함수

TransformVector(vector)  
  

TransformVector(x, y, z)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `vector` | 변환할 벡터 |
| `number` | `x` | x 좌표 |
| `number` | `y` | y 좌표 |
| `number` | `z` | z 좌표 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환 된 결과 |

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환된 벡터 |

## 예제 코드

```lua
local result = transform:TransformVector(x, y, z)
```
