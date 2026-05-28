---
title: isCaptured
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Properties/Cursor_isCaptured
source_path: LuaScript/Utilities/Cursor/Properties/Cursor_isCaptured.html
last_updated: "2026.04.06 오후 03:30"
---

# isCaptured

## 객체

> Cursor

## 설명

`isCaptured`는 커서가 캡처 모드로 전환된 상태인지 나타내는 값입니다.  

값이 `true`이면 커서 위치가 화면 중앙에 고정되고, 포인터 위치 이동 대신 마우스 델타 입력이 시점/조작 제어에 사용됩니다.  

보통 이 상태는 `isVisible = false`와 함께 운용되며, UI 상호작용보다 플레이 조작 입력을 우선 처리하는 구간에서 사용합니다.  

창 포커스 변경 등으로 잠금이 해제될 수 있으므로, UI 종료나 플레이 복귀 시점에 상태를 재확인하고 필요하면 다시 캡처하세요.

## 프로퍼티 정의

- **이름**: isCaptured
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local cursor = this.serviceApi.inputService.cursor
    if not cursor.isCaptured then
        cursor:SetCaptured()
    end
    this.scriptObject:Log("cursor captured = " .. tostring(cursor.isCaptured))
end
```
