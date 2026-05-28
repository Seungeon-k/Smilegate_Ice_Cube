---
title: isRunning
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isRunning
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isRunning.html
last_updated: "2026.04.06 오후 03:35"
---

# isRunning

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

isRunning은 펭귄 캐릭터가 현재 달리는 중인지 여부를 나타내는 읽기 전용(boolean) 프로퍼티입니다.  

캐릭터가 이동 입력을 받고 있으며, 속도가 일정 기준 이상일 때 자동으로 true로 전환됩니다.

## 프로퍼티 정의

- **이름**: `isRunning`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local penguin = someCharacter

-- 캐릭터가 달리고 있는지 확인
if penguin.isRunning then
    print("The penguin is running!")
end
```
