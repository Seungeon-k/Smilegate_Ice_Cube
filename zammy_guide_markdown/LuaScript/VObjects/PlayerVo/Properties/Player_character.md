---
title: character
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Properties/Player_character
source_path: LuaScript/VObjects/PlayerVo/Properties/Player_character.html
last_updated: "2026.04.06 오후 03:36"
---

# character

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`character`은(는) 현재 객체 상태를 나타내는 `Character` 프로퍼티입니다. 연관 API 호출 전후 상태 판단 기준으로 사용합니다. 후속 로직에서는 값 반영 시점과 참조 유효성을 함께 확인해야 합니다.  

`character` 값은 `Player`의 현재 상태를 직접 반영하므로 초기화/활성화 시점 차이를 고려해 사용 직전에 조회하는 방식이 안전합니다.  

멀티플레이에서는 `character`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: character
- **타입**: Character
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.character
    this.scriptObject:Log(tostring(value))
end
```
