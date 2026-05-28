---
title: isConfined
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Properties/Cursor_isConfined
source_path: LuaScript/Utilities/Cursor/Properties/Cursor_isConfined.html
last_updated: "2026.04.06 오후 03:30"
---

# isConfined

## 객체

> Cursor

## 설명

`isConfined`는 커서가 게임 창 경계 안으로 제한(Confined)되어 있는지 여부를 나타냅니다.  

멀티 모니터 환경에서 UI 조작 중 포인터 이탈을 막아야 할 때 유용하며, 비활성화하면 커서가 창 밖으로 이동할 수 있습니다.  

잠금 모드 변경은 `cursor:Set(lockState, visible)` 호출과 함께 발생하므로, 모드 전환 직후 값 확인으로 설정 적용 여부를 검증하세요.

## 프로퍼티 정의

- **이름**: isConfined
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local cursor = this.serviceApi.inputService.cursor
    this.scriptObject:Log("cursor confined = " .. tostring(cursor.isConfined))
end
```
