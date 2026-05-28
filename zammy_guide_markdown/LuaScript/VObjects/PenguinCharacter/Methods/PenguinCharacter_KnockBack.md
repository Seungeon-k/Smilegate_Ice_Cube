---
title: KnockBack
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_KnockBack
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_KnockBack.html
last_updated: "2026.04.06 오후 03:34"
---

# KnockBack

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

KnockBack은 캐릭터에게 지정된 방향으로 즉각적인 물리 충격(넉백 효과) 을 가하는 함수입니다.  

주로 적의 공격, 폭발, 스킬 효과 등에 의해 캐릭터가 밀려나는 상황에서 사용됩니다.  

이 함수는 캐릭터의 현재 위치에 상대적인 힘을 적용하여 캐릭터를 물리적으로 뒤로 밀어냅니다.  

`maxForceSpeed`는 선택 매개변수이며, 생략하면 `KnockBack(force, forceMode)` 형태로 호출할 수 있습니다

## 함수

KnockBack(forceMode, maxForceSpeed)  
  

KnockBack(force, forceMode, maxForceSpeed)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`ForceMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | `forceMode` | 물리력 적용 방식을 정의합니다. 예: ForceMode.Impulse는 순간적인 충격, ForceMode.Force는 점진적인 힘을 의미합니다. |
| `number` | `maxForceSpeed` | 넉백으로 인해 증가하는 속도(또는 힘 적용 결과 속도)의 상한입니다. 과도한 힘 값으로 속도가 비정상적으로 커지는 것을 방지할 때 사용합니다. |

### 반환값

없음

## 예제 코드

```lua
-- 넉백 예제
-- 플레이어를 뒤로 강하게 밀어내는 상황
local direction = Vector3(-1, 0, 0)  -- 왼쪽 방향
local knockbackForce = direction * 300  -- 힘의 크기 설정
character:KnockBack(knockbackForce, VFramework.ForceMode.Impulse)
```
