---
title: life
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Properties/Player_life
source_path: LuaScript/VObjects/PlayerVo/Properties/Player_life.html
last_updated: "2026.04.06 오후 03:36"
---

# life

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`life`은(는) 현재 생명 수를 나타내는 `number` 값입니다. 피격, 회복, 리스폰 규칙 처리의 기준으로 사용됩니다. 값 변경 시점에 연관 UI와 이벤트 처리를 함께 정리해야 흐름 불일치를 줄일 수 있습니다.  

`life` 값은 `Player`의 현재 상태를 직접 반영하므로 초기화/활성화 시점 차이를 고려해 사용 직전에 조회하는 방식이 안전합니다.  

멀티플레이에서는 `life`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: life
- **타입**: number
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.life
    this.scriptObject:Log(tostring(value))
end
```
