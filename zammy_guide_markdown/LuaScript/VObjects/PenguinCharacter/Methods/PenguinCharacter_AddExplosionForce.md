---
title: AddExplosionForce
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddExplosionForce
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddExplosionForce.html
last_updated: "2026.04.06 오후 03:34"
---

# AddExplosionForce

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

AddExplosionForce는 지정된 지점에서 발생한 폭발 효과를 캐릭터에 적용하여, 방사형(폭발 중심점 기준) 으로 밀려나도록 물리적인 힘을 가하는 함수입니다.  

이 함수는 폭발력, 반경, 상승 계수 등을 활용해 캐릭터에게 실감나는 물리 반응을 부여할 수 있습니다.  

주로 폭탄, 스킬 효과, 환경 폭발 이벤트 등에 사용됩니다.  

`maxForceSpeed`는 선택 선택 매개변수이며, 생략하면 `AddExplosionForce(force, position, radius, upwardsModifier, forceMode)` 형태로 호출할 수 있습니다.

## 함수

AddExplosionForce(force)  
  

AddExplosionForce(force, radius, upwardsModifier, forceMode, maxForceSpeed)  
  

AddExplosionForce(force, position, radius, upwardsModifier, forceMode, maxForceSpeed)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `force` | 폭발의 힘(Force) 값입니다. 값이 클수록 캐릭터에 가해지는 충격이 강해집니다. |
| `number` | `radius` | 폭발의 영향 반경(Radius) 값입니다. 캐릭터가 이 반경 안에 있어야 폭발력이 적용됩니다. |
| `number` | `upwardsModifier` | 상승 계수(Upwards Modifier) 값입니다. 값이 높을수록 폭발 시 캐릭터가 더 높이 떠오르게 됩니다. |
| [`ForceMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | `forceMode` | 물리력 적용 방식입니다. ForceMode에 따라 즉시 충격을 줄지(Impulse), 점진적으로 줄지(Force) 결정됩니다. |
| `number` | `maxForceSpeed` | 폭발력 적용으로 인해 증가하는 속도(또는 결과 속도)의 상한입니다. 과도한 폭발력으로 속도가 비정상적으로 커지는 것을 방지할 때 사용합니다. |

### 반환값

없음

없음.

## 예제 코드

```lua
-- 폭발 중심점 지정
local explosionCenter = Vector3(0, 0, 0)

-- 폭발력 적용
-- 파라미터: force(500), position, radius(10), upwardsModifier(2), ForceMode.Impulse
character:AddExplosionForce(500, explosionCenter, 10, 2, VFramework.ForceMode.Impulse)
```
