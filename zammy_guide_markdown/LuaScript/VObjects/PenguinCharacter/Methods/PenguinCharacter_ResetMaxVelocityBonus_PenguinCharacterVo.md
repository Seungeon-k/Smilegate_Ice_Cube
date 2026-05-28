---
title: ResetMaxVelocityBonus
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_ResetMaxVelocityBonus_PenguinCharacterVo
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_ResetMaxVelocityBonus_PenguinCharacterVo.html
last_updated: "2026.04.06 오후 03:35"
---

# ResetMaxVelocityBonus

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`ResetMaxVelocityBonus`는 펭귄 캐릭터의 최대 이동 속도 보너스 값([`MaxVelocityBonus`](../Properties/PenguinCharacter_MaxVelocityBonus.md))을 초기 상태로 리셋합니다.  

누적된 속도 보너스를 한 번에 정리해야 하는 상황(라운드 시작/종료, 리스폰, 상태 초기화, 디버그 리셋 등)에서 사용합니다.

일반적으로 초기 값은 0이며, 결과적으로 [`SetMaxVelocityBonus`](PenguinCharacter_SetMaxVelocityBonus_PenguinCharacterVo_number.md)(0)과 동일한 목적의 동작입니다.

## 함수

ResetMaxVelocityBonus()

### 매개변수

없음.

### 반환값

없음.

## 예제 코드

```lua
function this.ResetSpeedBonus(penguin)
    penguin:ResetMaxVelocityBonus()
    print("MaxVelocityBonus reset to: " .. tostring(penguin.MaxVelocityBonus))
end
```
