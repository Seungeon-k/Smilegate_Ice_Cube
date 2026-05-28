---
title: MovePosition
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_MovePosition_URigidbodyWrap_Vector3
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_MovePosition_URigidbodyWrap_Vector3.html
last_updated: "2026.04.06 오후 02:55"
---

# MovePosition

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 키네마틱 리지드바디를 주어진 위치로 이동시킵니다. 사용 시 주의할 점은 리지드바디가 키네마틱 상태여야 하며, 물리 엔진의 영향을 받지 않도록 설정되어 있어야 한다는 것입니다. 이 함수는 물리적 상호작용을 고려하지 않고 직접 위치를 설정하므로, 다른 물체와의 충돌이나 상호작용이 필요할 경우 적절한 방법을 사용해야 합니다.

## 함수

MovePosition(position)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `position` | 리지드바디 객체의 새로운 위치 |

### 반환값

없음

## 예제 코드

```lua
Rigidbody:MovePosition(position)
```
