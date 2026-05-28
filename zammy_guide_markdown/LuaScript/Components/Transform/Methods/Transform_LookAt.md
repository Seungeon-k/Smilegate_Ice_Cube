---
title: LookAt
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_LookAt
source_path: LuaScript/Components/Transform/Methods/Transform_LookAt.html
last_updated: "2026.04.06 오후 02:57"
---

# LookAt

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 함수는 변환을 회전시켜 주어진 위치를 바라보도록 합니다. 주어진 위치는 월드 좌표계에서의 점으로, 이 점을 향해 변환의 앞쪽 벡터가 향하도록 합니다. 이 메서드는 주로 카메라나 오브젝트가 특정 대상을 바라보도록 설정할 때 유용합니다.

이 함수는 변환을 회전시켜 주어진 위치를 바라보도록 합니다. `worldPosition`은 바라볼 지점을 나타내며, `worldUp`은 위쪽 방향을 지정하는 벡터입니다. 이 두 인수를 통해 객체의 방향을 조정할 수 있습니다. 사용 시 주의할 점은, `worldUp` 벡터가 올바른 방향을 가리키도록 설정해야 한다는 것입니다. 잘못된 방향을 지정할 경우 예기치 않은 결과가 발생할 수 있습니다.

## 함수

LookAt(worldPosition)  
  

LookAt(worldPosition, worldUp)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `worldPosition` | 바라볼 점 바라볼 지점 |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `worldUp` | 위쪽 방향을 지정하는 벡터 |

### 반환값

없음

## 예제 코드

```lua
Transform:LookAt(worldPosition, worldUp)
```
