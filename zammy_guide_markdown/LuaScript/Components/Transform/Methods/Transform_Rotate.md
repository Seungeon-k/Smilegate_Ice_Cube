---
title: Rotate
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_Rotate
source_path: LuaScript/Components/Transform/Methods/Transform_Rotate.html
last_updated: "2026.04.06 오후 02:57"
---

# Rotate

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

Transform.Rotate를 사용하여 다양한 방식으로 게임 오브젝트를 회전시킬 수 있습니다. 회전은 일반적으로 쿼터니언이 아닌 오일러 각도로 제공됩니다. 이 메서드는 게임 오브젝트의 회전을 적용하는 데 사용되며, 주의할 점은 회전 값이 올바른 형식으로 제공되어야 한다는 것입니다.

이 메서드는 Object를 다양한 방식으로 회전시키는 데 사용됩니다. 회전은 일반적으로 쿼터니언이 아닌 오일러 각도로 제공됩니다. 이 메서드를 사용할 때는 회전의 기준이 되는 좌표계를 명확히 이해하고 있어야 합니다. 예를 들어, 로컬 좌표계에서 회전할지, 세계 좌표계에서 회전할지를 결정해야 합니다.

Transform.Rotate 메서드는 Object를 다양한 방식으로 회전시키는 데 사용됩니다. 회전은 일반적으로 쿼터니언이 아닌 오일러 각도로 제공됩니다. 이 메서드를 사용할 때는 회전 축과 각도를 정확히 설정해야 하며, 잘못된 값이 입력될 경우 예상치 못한 결과가 발생할 수 있습니다.

Transform.Rotate를 사용하여 다양한 방식으로 게임 오브젝트를 회전시킬 수 있습니다. 회전은 종종 쿼터니언이 아닌 오일러 각도로 제공됩니다. 이 메서드는 회전 축과 각도를 지정하여 게임 오브젝트를 회전시키며, 회전 기준을 설정할 수 있습니다. 회전 기준은 게임 오브젝트의 로컬 좌표계 또는 월드 좌표계 중 하나로 설정할 수 있습니다.

Transform.Rotate는 Object를 다양한 방식으로 회전시키는 데 사용됩니다. 회전은 일반적으로 쿼터니언이 아닌 오일러 각도로 제공됩니다. 이 메서드는 X, Y, Z 축을 기준으로 각각의 각도를 입력받아 회전을 수행합니다. 회전 각도는 도 단위로 입력해야 하며, 유의사항으로는 회전이 누적되므로 연속적으로 호출할 경우 예상치 못한 결과가 발생할 수 있습니다.

Transform.Rotate를 사용하여 다양한 방식으로 게임 오브젝트를 회전시킬 수 있습니다. 회전은 일반적으로 쿼터니언이 아닌 오일러 각도로 제공됩니다. 이 메서드는 게임 오브젝트를 X, Y, Z 축을 기준으로 회전시키며, 회전의 기준이 되는 공간을 선택할 수 있습니다.

## 함수

Rotate(eulers)  
  

Rotate(axis, angle)  
  

Rotate(xAngle, yAngle, zAngle)  
  

Rotate(xAngle, yAngle, zAngle, relativeTo)  
  

Rotate(axis, angle, relativeTo)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `eulers` | 적용할 회전의 오일러 각도 |
| `number` | `angle` | 로컬 좌표계 또는 세계 좌표계에 상대하여 회전할지를 결정 적용할 회전의 각도(도) 적용할 회전의 각도(도 단위) |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `axis` | 적용할 회전의 오일러 각도 회전을 적용할 축 |
| [`Space`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/Space) | `relationTo` | 로컬 좌표계 또는 월드 좌표계에 따라 회전할지를 결정 |
| `number` | `xAngle` | X 축을 기준으로 회전시키는 각도(도) X 축을 기준으로 회전할 각도(도) |
| `number` | `yAngle` | Y 축을 기준으로 회전시키는 각도(도) Y 축을 기준으로 회전할 각도(도) |
| `number` | `zAngle` | Z 축을 기준으로 회전시키는 각도(도) Z 축을 기준으로 회전할 각도(도) |
| [`Space`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/Space) | `relativeTo` | 로컬 좌표계 또는 월드 좌표계에 상대적으로 회전할지를 결정 |

### 반환값

없음

## 예제 코드

```lua
Transform:Rotate(xAngle, yAngle, zAngle, relativeTo)
```
