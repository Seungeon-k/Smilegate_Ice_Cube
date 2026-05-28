---
title: AddExplosionForce
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Methods/Rigidbody_AddExplosionForce
source_path: LuaScript/Components/Rigidbody/Methods/Rigidbody_AddExplosionForce.html
last_updated: "2026.04.06 오후 02:54"
---

# AddExplosionForce

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

이 함수는 강체에 폭발 효과를 시뮬레이션하는 힘을 적용합니다. 폭발의 힘은 거리의 영향을 받을 수 있으며, 폭발의 중심과 반경을 지정하여 효과를 조절할 수 있습니다. 이 함수를 사용할 때는 폭발의 위치와 반경을 적절히 설정하여 원하는 효과를 얻도록 해야 합니다.  

`upwardsModifier`, `mode`는 선택 매개변수들입니다. 생략하면 `AddExplosionForce(force, position, radius)` 형태로 호출할 수 있습니다.

## 함수

AddExplosionForce(force, position, radius)  
  

AddExplosionForce(force, position, radius, upwardsModifier)  
  

AddExplosionForce(force, position, radius, upwardsModifier, mode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `float` | `force` | 숫자 입력값입니다. |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `position` | 월드 좌표 기준 위치 값입니다. |
| `float` | `radius` | 숫자 입력값입니다. |
| `float` | `upwardsModifier` | 숫자 입력값입니다. 생략하면 해당 인자를 받지 않는 호출 형태가 사용됩니다. |
| [`ForceMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | `mode` | 동작 모드/적용 방식을 지정합니다. 생략하면 해당 인자를 받지 않는 호출 형태가 사용됩니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| `void` | 모든 호출 조합에서 값을 반환하지 않습니다. |

## 예제 코드

```lua
Rigidbody:AddExplosionForce(explosionForce, explosionPosition, explosionRadius)
```
