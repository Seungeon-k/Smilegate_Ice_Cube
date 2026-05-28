---
title: SetMaxVelocityBonus
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetMaxVelocityBonus_PenguinCharacterVo_number
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetMaxVelocityBonus_PenguinCharacterVo_number.html
last_updated: "2026.04.06 오후 03:35"
---

# SetMaxVelocityBonus

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`SetMaxVelocityBonus`는 펭귄 캐릭터의 최대 이동 속도 보너스 값([`MaxVelocityBonus`](../Properties/PenguinCharacter_MaxVelocityBonus.md)) 을 지정한 값으로 직접 설정합니다.  

[`AddMaxVelocityBonus`](PenguinCharacter_AddMaxVelocityBonus_PenguinCharacterVo_number.md)/[`RemoveMaxVelocityBonus`](PenguinCharacter_RemoveMaxVelocityBonus_PenguinCharac_F69575037F.md)가 누적 증감 방식이라면, 이 함수는 상태 전환이나 초기화처럼 보너스 값을 특정 값으로 고정해야 할 때 사용합니다.

이 값은 현재 이동 속도를 바로 변경하기보다, 최대 속도 제한(상한)에 추가로 반영되는 보정치로 사용됩니다.

## 함수

SetMaxVelocityBonus(value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | value | [`MaxVelocityBonus`](../Properties/PenguinCharacter_MaxVelocityBonus.md)에 설정할 값입니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.ResetSpeedBonus(penguin)
    -- 최대 속도 보너스 초기화
    penguin:SetMaxVelocityBonus(0)
end
```
