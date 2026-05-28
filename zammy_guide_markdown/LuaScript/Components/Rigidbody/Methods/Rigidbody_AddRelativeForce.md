---
title: AddRelativeForce
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_AddRelativeForce
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_AddRelativeForce.html
last_updated: "2026.04.06 오후 02:54"
---

# AddRelativeForce

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 Rigidbody에 힘을 추가하며, 해당 힘은 Rigidbody의 로컬 좌표계에 상대적으로 적용됩니다. 사용 시 주의할 점은 힘 벡터가 로컬 좌표계로 표현되어야 한다는 것입니다. 이 함수는 물리적 상호작용을 위해 주로 사용되며, Rigidbody가 활성화되어 있어야 정상적으로 작동합니다.

이 함수는 Rigidbody에 상대적인 힘을 추가합니다. 힘은 로컬 좌표계에서 정의되며, 물체의 질량에 따라 다르게 작용합니다. 이 메서드는 물리적 상호작용을 위해 주로 사용되며, 적절한 ForceMode를 선택하여 힘의 적용 방식을 조정할 수 있습니다.

이 함수는 Rigidbody에 힘을 추가하여 해당 객체의 로컬 좌표계에 상대적으로 작용합니다. x, y, z 축에 대한 힘의 크기를 지정하여 물체의 움직임을 제어할 수 있습니다. 이 함수는 물체의 현재 회전 상태에 따라 힘이 적용되므로, 물체가 회전하는 경우 힘의 방향이 예상과 다를 수 있습니다.

이 함수는 Rigidbody에 상대 좌표계에 따라 힘을 추가합니다. x, y, z 축에 대한 힘의 크기를 지정할 수 있으며, 힘의 적용 방식은 ForceMode를 통해 선택할 수 있습니다. 이 함수는 물리적 상호작용을 위해 사용되며, 적절한 힘의 크기와 모드를 선택하는 것이 중요합니다. 잘못된 값이 입력될 경우 예기치 않은 결과가 발생할 수 있습니다.

## 함수

AddRelativeForce(force)  
  

AddRelativeForce(force, mode)  
  

AddRelativeForce(x, y, z)  
  

AddRelativeForce(x, y, z, mode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `force` | 로컬 좌표계에서의 힘 벡터 |
| [`ForceMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | `mode` | 힘의 적용 방식 |
| `number` | `x` | 로컬 x축을 따라 힘의 크기 |
| `number` | `y` | 로컬 y축을 따라 힘의 크기 |
| `number` | `z` | 로컬 z축을 따라 힘의 크기 |

### 반환값

없음

## 예제 코드

```lua
Rigidbody:AddRelativeForce(x, y, z, mode)
```
