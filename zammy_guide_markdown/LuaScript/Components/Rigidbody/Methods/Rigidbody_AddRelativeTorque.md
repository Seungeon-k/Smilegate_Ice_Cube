---
title: AddRelativeTorque
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_AddRelativeTorque
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_AddRelativeTorque.html
last_updated: "2026.04.06 오후 02:54"
---

# AddRelativeTorque

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 Rigidbody에 상대적인 좌표계에서 토크를 추가합니다. 주어진 토크 벡터는 로컬 좌표계에 따라 적용되며, 물체의 회전을 제어하는 데 사용됩니다. 이 메서드는 물리적 상호작용을 위해 주로 사용되며, Rigidbody가 활성화되어 있어야 정상적으로 작동합니다.

이 함수는 Rigidbody에 상대적인 토크를 추가합니다. 로컬 좌표계에서의 토크 벡터를 사용하여 물체의 회전을 제어할 수 있습니다. 이 메서드는 물체의 질량을 고려하여 힘을 적용합니다.

이 함수는 Rigidbody에 상대적인 토크를 추가합니다. 로컬 좌표계에 따라 x, y, z 축을 기준으로 토크의 크기를 지정할 수 있습니다. 이 메서드는 물리적 상호작용을 조정하는 데 유용하며, 객체의 회전을 제어하는 데 사용됩니다.

이 함수는 Rigidbody에 상대적인 좌표계에 따라 토크를 추가합니다. x, y, z 축에 대한 크기를 지정하여 물체의 회전을 제어할 수 있습니다.

토크는 물체의 회전 운동을 변경하는 데 사용되며, ForceMode 매개변수를 통해 적용 방식을 선택할 수 있습니다. 이 함수는 물체의 물리적 특성에 따라 다르게 작용할 수 있으므로, 적절한 값을 설정하는 것이 중요합니다.

## 함수

AddRelativeTorque(torque)  
  

AddRelativeTorque(torque, mode)  
  

AddRelativeTorque(x, y, z)  
  

AddRelativeTorque(x, y, z, mode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `torque` | 로컬 좌표계의 토크 벡터 로컬 좌표계에서의 토크 벡터 |
| [`ForceMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | `mode` | 힘의 적용 방식 적용할 힘의 방식 |
| `number` | `x` | 로컬 x축을 따라 토크의 크기 |
| `number` | `y` | 로컬 y축을 따라 토크의 크기 |
| `number` | `z` | 로컬 z축을 따라 토크의 크기 |

### 반환값

없음

## 예제 코드

```lua
Rigidbody:AddRelativeTorque(x, y, z, mode)
```
