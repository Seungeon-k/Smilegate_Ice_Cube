---
title: isKnockedDown
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isKnockedDown
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isKnockedDown.html
last_updated: "2026.04.06 오후 03:35"
---

# isKnockedDown

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

isKnockedDown은 펭귄 캐릭터가 현재 넘어져 있는 상태(Knockdown 상태) 인지를 나타내는 읽기 전용(boolean) 프로퍼티입니다.  

캐릭터가 넉백, 충돌, 폭발, 특정 아이템의 효과 등으로 인해 균형을 잃고 쓰러졌을 때 이 값이 true로 설정됩니다.

## 프로퍼티 정의

- **이름**: `isKnockedDown`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local penguin = someCharacter

-- 펭귄이 넘어졌는지 확인
if penguin.isKnockedDown then
    print("The penguin has been knocked down!")
end
```
