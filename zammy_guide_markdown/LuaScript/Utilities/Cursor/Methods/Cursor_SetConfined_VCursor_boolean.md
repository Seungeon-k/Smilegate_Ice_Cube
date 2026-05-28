---
title: SetConfined
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Methods/Cursor_SetConfined_VCursor_boolean
source_path: LuaScript/Utilities/Cursor/Methods/Cursor_SetConfined_VCursor_boolean.html
last_updated: "2026.04.06 오후 03:30"
---

# SetConfined

## 객체

> Cursor

## 설명

`SetConfined`는 `confined` 값을 적용해 상태를 갱신합니다. 설정 직후 연관 시스템의 반영 순서를 맞춰 호출해야 예기치 않은 동기화 오차를 줄일 수 있습니다.  

`SetConfined`는 호출 프레임에 바로 반영되므로, 같은 프레임에서 중복 호출되지 않게 실행 순서를 고정하세요.  

`SetConfined`는 `Confined` 값을 덮어쓰므로, 동시에 여러 스크립트가 호출하지 않도록 상태 갱신 책임을 단일화하세요.

## 함수

SetConfined(confined)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| boolean | confined | confined는 true/false 상태 제어 플래그입니다. 기본 동작과 반대 동작을 전환할 때 사용합니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    target:SetConfined(false)
end
```
