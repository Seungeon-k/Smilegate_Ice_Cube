---
title: RemoveMaxVelocityBonus
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RemoveMaxVelocityBonus_PenguinCharac_F69575037F
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RemoveMaxVelocityBonus_PenguinCharac_F69575037F.html
last_updated: "2026.04.06 오후 03:35"
---

# RemoveMaxVelocityBonus

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`RemoveMaxVelocityBonus`는 펭귄 캐릭터의 최대 이동 속도 보너스 값([`MaxVelocityBonus`](../Properties/PenguinCharacter_MaxVelocityBonus.md)) 에서 delta만큼을 차감합니다.  

가속 버프/효과를 해제하거나, 디버프로 인해 증가했던 최대 속도 보너스를 되돌릴 때 사용합니다.

일반적으로 delta는 양수 값을 전달하며, 내부적으로 MaxVelocityBonus -= delta 형태로 반영되는 동작을 의미합니다.

## 함수

RemoveMaxVelocityBonus(delta)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | delta | [`MaxVelocityBonus`](../Properties/PenguinCharacter_MaxVelocityBonus.md)에서 차감할 값입니다. 보통 양수를 전달합니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.RemoveSpeedBonus(penguin)
    -- 최대 속도 보너스 2만큼 차감
    penguin:RemoveMaxVelocityBonus(2)
    print("MaxVelocityBonus: " .. tostring(penguin.MaxVelocityBonus))
end
```
