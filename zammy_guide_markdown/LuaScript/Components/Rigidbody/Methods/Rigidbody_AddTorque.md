---
title: AddTorque
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_AddTorque
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_AddTorque.html
last_updated: "2026.04.06 오후 02:54"
---

# AddTorque

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 리지드바디에 토크를 추가합니다. 주어진 토크 벡터는 월드 좌표계에서 정의됩니다. 이 메서드는 물리적 상호작용을 위해 사용되며, 리지드바디의 회전 운동에 영향을 미칩니다. 사용 시 주의할 점은 토크의 방향과 크기가 리지드바디의 회전 속도에 직접적인 영향을 미친다는 것입니다.

이 함수는 리지드바디에 토크를 추가합니다. 토크는 물체의 회전을 유도하는 힘으로, 주어진 벡터 방향으로 작용합니다. 두 번째 인수인 `mode`는 토크의 적용 방식을 결정합니다. 이 함수는 리지드바디의 물리적 특성에 따라 다르게 작용할 수 있으므로, 적절한 값을 선택하는 것이 중요합니다. 예를 들어, `Impulse` 모드를 사용하면 즉각적인 힘이 작용하여 빠른 회전을 유도할 수 있습니다.

이 함수는 리지드바디에 토크를 추가합니다. x, y, z 축을 따라 각각의 크기를 지정하여 회전력을 적용할 수 있습니다. 이 메서드는 물리적 상호작용을 위해 사용되며, 적절한 값으로 설정해야 원하는 회전 효과를 얻을 수 있습니다.

이 함수는 리지드바디에 토크를 추가합니다. x, y, z 축을 따라 각각의 크기를 지정하여 회전력을 적용할 수 있습니다. `mode` 매개변수는 적용할 토크의 유형을 결정합니다. 이 함수는 리지드바디의 물리적 특성에 따라 다르게 작용할 수 있으므로, 사용 시 주의가 필요합니다.

## 함수

AddTorque(torque)  
  

AddTorque(torque, mode)  
  

AddTorque(x, y, z)  
  

AddTorque(x, y, z, mode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `torque` | 월드 좌표계에서의 토크 벡터 |
| [`ForceMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | `mode` | 적용할 토크의 유형 |
| `number` | `x` | 월드 x축을 따라 토크의 크기 |
| `number` | `y` | 월드 y축을 따라 토크의 크기 |
| `number` | `z` | 월드 z축을 따라 토크의 크기 |

### 반환값

없음

## 예제 코드

```lua
Rigidbody:AddTorque(x, y, z, mode)
```
