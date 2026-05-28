---
title: isJumping
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isJumping
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isJumping.html
last_updated: "2026.04.06 오후 03:35"
---

# isJumping

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

이 프로퍼티는 펭귄 캐릭터가 현재 점프 중인지 여부를 나타내는 boolean 값입니다.

## 프로퍼티 정의

- **이름**: `isJumping`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local penguin = someCharacter
if penguin.isJumping then
    penguin:StopState(CharacterState.Jump)
    print("Jump state cleared.")
end
```

## 참고 사항

isJumping은 CharacterState.Jump 상태와 자동 연동되어 있습니다.
