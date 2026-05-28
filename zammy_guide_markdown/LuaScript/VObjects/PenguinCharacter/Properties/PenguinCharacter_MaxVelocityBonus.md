---
title: MaxVelocityBonus
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_MaxVelocityBonus
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_MaxVelocityBonus.html
last_updated: "2026.04.06 오후 03:35"
---

# MaxVelocityBonus

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`MaxVelocityBonus`는 펭귄 캐릭터의 최대 이동 속도(Max Velocity) 에 추가로 더해지는 보너스 값입니다.  

버프, 장비 효과, 지형 효과(가속 구간) 등으로 최대 속도 상한을 일시적으로 확장할 때 사용되며, 현재 이동 속도를 직접 변경하는 값이 아니라 최대 속도 제한에 반영되는 값입니다.

## 프로퍼티 정의

- **이름**: MaxVelocityBonus
- **타입**: number
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.PrintMaxVelocityBonus(penguin)
    local bonus = penguin.MaxVelocityBonus
    print("Max velocity bonus: " .. tostring(bonus))
end
```
