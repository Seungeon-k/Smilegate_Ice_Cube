---
title: SetRigidbodyConstraints
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetRigidbodyConstraints_PenguinChara_951D17D9CC
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetRigidbodyConstraints_PenguinChara_951D17D9CC.html
last_updated: "2026.04.06 오후 03:35"
---

# SetRigidbodyConstraints

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

SetRigidbodyConstraints는 캐릭터의 [`Rigidbody`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody) 제약(Constraints) 을 설정합니다.  

[`RigidbodyConstraints`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/RigidbodyConstraints)의 의미에 따라 이동/회전 축 고정 또는 전체 고정을 제어할 때 사용합니다.

## 함수

SetRigidbodyConstraints(constraints)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`RigidbodyConstraints`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/RigidbodyConstraints) | constraints | 적용할 제약 값입니다. 이동/회전 축별 고정 또는 조합 값을 전달합니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.FreezeAll(character)
    -- 전체 이동/회전 고정
    character:SetRigidbodyConstraints(VFramework.RigidbodyConstraints.FreezeAll)
end
```
