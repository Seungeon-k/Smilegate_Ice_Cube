---
title: SetMass
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetMass_PenguinCharacterVo_number
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetMass_PenguinCharacterVo_number.html
last_updated: "2026.04.06 오후 03:35"
---

# SetMass

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`SetMass`는 캐릭터 [`Rigidbody`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)의 질량(mass) 값을 설정합니다.  

질량은 힘/충돌 반응(가속, 밀림, 넉백 체감 등)에 영향을 주므로, 상태(거대화/경량화), 특수 기믹, 연출 구간에서 물리 반응을 조정할 때 사용합니다.

## 함수

SetMass(mass)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | mass | 설정할 질량 값입니다. 일반적으로 0보다 큰 값을 사용해야 하며, 과도하게 큰/작은 값은 충돌 반응이 부자연스러워질 수 있습니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.ApplyHeavy(character)
    -- 무겁게 만들어 밀림/넉백 반응을 줄이는 연출 예시
    character:SetMass(10)
end
```
