---
title: AddForce
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_AddForce
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_AddForce.html
last_updated: "2026.04.06 오후 02:54"
---

# AddForce

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 Rigidbody에 힘을 추가합니다. 힘은 월드 좌표계에서의 벡터로 표현됩니다. 이 메서드는 물리적 상호작용을 위해 사용되며, Rigidbody의 움직임에 영향을 미칩니다. 사용 시 주의할 점은 힘의 크기와 방향이 Rigidbody의 현재 상태에 따라 다르게 작용할 수 있다는 것입니다. 예를 들어, 이미 움직이고 있는 Rigidbody에 힘을 추가하면 그 속도가 증가할 수 있습니다.

이 함수는 Rigidbody에 힘을 추가합니다. 힘은 월드 좌표계에서 벡터 형태로 제공되며, 힘의 적용 방식은 ForceMode를 통해 지정할 수 있습니다. 이 함수는 물리적 상호작용을 위해 사용되며, 적절한 힘의 크기와 방향을 설정하는 것이 중요합니다. 잘못된 힘의 적용은 예기치 않은 물리적 결과를 초래할 수 있습니다.

이 함수는 Rigidbody에 힘을 추가합니다. 힘은 월드 좌표계의 x, y, z 축을 따라 적용됩니다. 이 메서드는 물리적 상호작용을 위해 사용되며, Rigidbody의 움직임에 직접적인 영향을 미칩니다. 사용 시 주의할 점은 힘의 크기와 방향이 Rigidbody의 현재 상태에 따라 다르게 작용할 수 있다는 것입니다. 예를 들어, 이미 움직이고 있는 Rigidbody에 힘을 추가하면 그 속도가 증가할 수 있습니다.

이 함수는 Rigidbody에 힘을 추가합니다. 힘은 x, y, z 축을 따라 적용되며, 힘의 종류는 ForceMode를 통해 지정할 수 있습니다. 이 메서드는 물리적 상호작용을 위해 사용되며, 적절한 힘의 크기와 방향을 설정하는 것이 중요합니다. 잘못된 값이 입력될 경우 예기치 않은 결과가 발생할 수 있습니다.

## 함수

AddForce(force)  
  

AddForce(force, mode)  
  

AddForce(x, y, z)  
  

AddForce(x, y, z, mode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `force` | 월드 좌표계에서의 힘 벡터 |
| [`ForceMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | `mode` | 적용할 힘의 유형 적용할 힘의 종류 |
| `number` | `x` | 월드 x축을 따라 힘의 크기 세계 x축을 따라 힘의 크기 |
| `number` | `y` | 월드 y축을 따라 힘의 크기 세계 y축을 따라 힘의 크기 |
| `number` | `z` | 월드 z축을 따라 힘의 크기 세계 z축을 따라 힘의 크기 |

### 반환값

없음

## 예제 코드

```lua
Rigidbody:AddForce(x, y, z, mode)
```
