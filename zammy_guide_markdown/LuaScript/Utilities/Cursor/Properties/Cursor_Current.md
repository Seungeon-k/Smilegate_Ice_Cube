---
title: Current
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Properties/Cursor_Current
source_path: LuaScript/Utilities/Cursor/Properties/Cursor_Current.html
last_updated: "2026.04.06 오후 03:30"
---

# Current

## 객체

> Cursor

## 설명

`Current`은(는) 현재 객체 상태를 나타내는 `State` 프로퍼티입니다. 연관 API 호출 전후 상태 판단 기준으로 사용합니다. 후속 로직에서는 값 반영 시점과 참조 유효성을 함께 확인해야 합니다.  

`Current` 값은 `Cursor`의 현재 상태를 직접 반영하므로 초기화/활성화 시점 차이를 고려해 사용 직전에 조회하는 방식이 안전합니다.  

멀티플레이에서는 `Current`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: Current
- **타입**: State
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.Current
    this.scriptObject:Log(tostring(value))
end
```
