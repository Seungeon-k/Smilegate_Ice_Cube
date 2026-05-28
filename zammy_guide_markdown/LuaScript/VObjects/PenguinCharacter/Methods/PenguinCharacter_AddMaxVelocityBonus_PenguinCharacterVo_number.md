---
title: AddMaxVelocityBonus
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddMaxVelocityBonus_PenguinCharacterVo_number
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddMaxVelocityBonus_PenguinCharacterVo_number.html
last_updated: "2026.04.06 오후 03:34"
---

# AddMaxVelocityBonus

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`AddMaxVelocityBonus`는 펭귄 캐릭터의 최대 이동 속도 보너스 값([`MaxVelocityBonus`](../Properties/PenguinCharacter_MaxVelocityBonus.md)) 에 delta를 누적 적용합니다.  

버프/디버프, 가속 구간, 아이템 효과처럼 최대 속도 상한을 일정량 올리거나(+) 내릴(-) 때 사용합니다.

이 함수는 현재 이동 속도를 직접 바꾸기보다, 최대 속도 제한에 반영되는 보너스 값을 변경하는 용도입니다.

## 함수

AddMaxVelocityBonus(delta)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | delta | [`MaxVelocityBonus`](../Properties/PenguinCharacter_MaxVelocityBonus.md)에 더할 변화량입니다. 양수면 최대 속도 보너스를 증가시키고, 음수면 감소시킵니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.ApplySpeedBuff(penguin)
    -- 최대 속도 보너스 +2
    penguin:AddMaxVelocityBonus(2)
    print("MaxVelocityBonus: " .. tostring(penguin.MaxVelocityBonus))
end

function this.RemoveSpeedBuff(penguin)
    -- 최대 속도 보너스 -2 (버프 해제)
    penguin:AddMaxVelocityBonus(-2)
    print("MaxVelocityBonus: " .. tostring(penguin.MaxVelocityBonus))
end
```
