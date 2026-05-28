---
title: externalForceScale
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_externalForceScale
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_externalForceScale.html
last_updated: "2026.04.06 오후 03:35"
---

# externalForceScale

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

외부의 힘에 의한 영향에 대해 값을 배수로 받는 설정 값입니다.  

외부 영향을 적게 혹은 많게 받기 위하여 설정 할 수 있습니다.  

초기 값은 1로 되어 있습니다.

## 프로퍼티 정의

- **이름**: `externalForceScale`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local penguin = someCharacter

-- 외부 힘을 반만 영향을 받게 설정.
penguin.externalForceScale = 0.5
```

## 참고 사항

외부의 힘은 AddForce, KnockDown, AddExplosionForce 와 같이 스크립트로 직접 영향을 미치는 힘들 대상으로 합니다.
