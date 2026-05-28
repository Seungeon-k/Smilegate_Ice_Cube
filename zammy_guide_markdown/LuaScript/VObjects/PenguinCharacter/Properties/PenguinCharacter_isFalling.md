---
title: isFalling
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isFalling
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isFalling.html
last_updated: "2026.04.06 오후 03:35"
---

# isFalling

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

isFalling은 펭귄 캐릭터가 현재 공중에 있으며 낙하 중인지 여부를 나타내는 읽기 전용(boolean) 프로퍼티입니다.  

점프 후 하강 단계이거나, 발판에서 떨어졌을 때, 혹은 넉백 등으로 인해 공중 상태가 되었을 때 자동으로 true로 전환됩니다.

이 값은 캐릭터가 지면에 닿아 있지 않은 상태를 간단히 확인할 수 있도록 해주며,  

착지 시점 감지, 낙하 데미지 계산, 공중 제어 제한 등 다양한 게임 로직을 구성하는 데 활용됩니다.

## 프로퍼티 정의

- **이름**: `isFalling`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local penguin = someCharacter

-- 낙하 중인지 체크
if penguin.isFalling then
    print("The penguin is running!")
end
```
