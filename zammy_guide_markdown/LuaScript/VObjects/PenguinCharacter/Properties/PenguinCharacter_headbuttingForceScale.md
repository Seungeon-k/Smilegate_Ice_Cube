---
title: headbuttingForceScale
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_headbuttingForceScale
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_headbuttingForceScale.html
last_updated: "2026.04.06 오후 03:35"
---

# headbuttingForceScale

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

캐릭터가 headbutting 할 때 충돌 하는 대상에 가해지는 힘의 Scale 값 입니다.  

headbutting의 힘들 감쇠하고나 강화 할 때 사용되어집니다.  

초기값은 1입니다.

이 값이 적용되는 충돌 대상은 캐릭터와 레이어가 DynamicObject로 설정되어 있는 객체입니다.

## 프로퍼티 정의

- **이름**: `headbuttingForceScale`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local penguin = someCharacter

-- headbutting 할때 힘들 두배로 설정
penguin.headbuttingForceScale = 2
```
