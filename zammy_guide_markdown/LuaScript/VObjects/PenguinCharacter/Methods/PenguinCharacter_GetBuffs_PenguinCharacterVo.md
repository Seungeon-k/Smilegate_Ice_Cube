---
title: GetBuffs
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetBuffs_PenguinCharacterVo
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetBuffs_PenguinCharacterVo.html
last_updated: "2026.04.06 오후 03:34"
---

# GetBuffs

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`GetBuffs`는 현재의 캐릭터 객체가 적용 받고 있는 [`Buff`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo)들을 LuaTable 형태의 인자로 [`Buff`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo)로 얻어 옵니다.  

캐릭터가 어떤 버프를 받고 있는지 확인한 뒤, 그에 따른 효과 적용 로직을 구현할 때 사용합니다.

## 함수

GetBuffs()

### 매개변수

없음.

### LuaTable 데이터 타입

- 반환 테이블: Buff[]

### 반환값

`GetBuffs` 호출 시점에 캐릭터에 적용되어 있는 [`Buff`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo)들을 `LuaTable` 데이터로 반환합니다.

## 예제 코드

```lua
function this.CheckBuff(character)
    local buffs = character:GetBuffs()

    for i, v in ipairs(buffs) do
        local buff = buffs[i]
        -- buff.id
    end
end
```
