---
title: RotateAround
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_RotateAround_UTransformWrap_Vector3_Vector3_number
source_path: LuaScript/Components/Transform/Methods/Transform_RotateAround_UTransformWrap_Vector3_Vector3_number.html
last_updated: "2026.04.06 오후 02:57"
---

# RotateAround

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 함수는 주어진 점을 중심으로 지정된 축을 따라 회전합니다. 회전은 월드 좌표계에서 이루어지며, 각도는 도 단위로 지정됩니다. 이 메서드는 회전의 결과를 반환하지 않으며, 주로 게임 오브젝트의 회전을 조정하는 데 사용됩니다. 사용 시 주의할 점은 회전 축과 회전 중심이 올바르게 설정되어야 원하는 결과를 얻을 수 있다는 것입니다.

## 함수

RotateAround(point, axis, angle)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `point` | 회전 중심의 위치 |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `axis` | 회전할 축의 방향 |
| `number` | `angle` | 회전할 각도 |

### 반환값

없음

## 예제 코드

```lua
Transform:RotateAround(point, axis, angle)
```
