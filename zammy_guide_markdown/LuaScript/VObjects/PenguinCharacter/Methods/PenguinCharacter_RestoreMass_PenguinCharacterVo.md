---
title: RestoreMass
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreMass_PenguinCharacterVo
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreMass_PenguinCharacterVo.html
last_updated: "2026.04.06 오후 03:35"
---

# RestoreMass

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`RestoreMass`는 캐릭터 [`Rigidbody`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)의 질량(mass)을 이전 값으로 복구합니다.  

SetMass로 질량을 변경해 연출/상태 효과(무겁게/가볍게)를 적용한 뒤, 효과가 끝났을 때 원래 질량으로 되돌릴 때 사용합니다.

## 함수

RestoreMass()

### 매개변수

없음.

### 반환값

없음.

## 예제 코드

```lua
function this.ApplyHeavyTemporarily(character)
    -- 질량 변경
    character:SetMass(10)

    -- (연출/상태 종료 시점)
    character:RestoreMass()
end
```
