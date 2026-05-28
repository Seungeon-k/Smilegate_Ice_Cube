---
title: isHeadButting
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isHeadButting
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isHeadButting.html
last_updated: "2026.04.06 오후 03:35"
---

# isHeadButting

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

이 프로퍼티는 펭귄 캐릭터가 현재 머리 박기(HeadButt) 상태에 있는지를 나타내는 불리언 값입니다.

## 프로퍼티 정의

- **이름**: `isHeadButting`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local penguin = someCharacter

if penguin.isHeadButting then
    print("Currently headbutting! Collision detection is enabled.")
end
```

## 참고 사항

isHeadButting은 [CharacterState](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/CharacterState).HeadButt 상태와 자동으로 연동됩니다.
