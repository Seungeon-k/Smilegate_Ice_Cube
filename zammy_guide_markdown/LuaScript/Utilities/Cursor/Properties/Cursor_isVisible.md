---
title: isVisible
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Properties/Cursor_isVisible
source_path: LuaScript/Utilities/Cursor/Properties/Cursor_isVisible.html
last_updated: "2026.04.06 오후 03:30"
---

# isVisible

## 객체

> Cursor

## 설명

`isVisible`는 현재 프레임에서 커서 렌더링이 화면에 노출되는지 여부를 나타냅니다.  

UI 패널을 열어 포인터 상호작용을 받을 때는 `true`, 전투/조작 구간처럼 카메라 회전에 집중할 때는 `false`로 관리하는 흐름이 일반적입니다.  

커서 잠금(`CursorLockMode`)과 함께 상태가 바뀌므로, 상태 전환 직후 `cursor.isCaptured`를 같이 확인해 입력 모드가 의도대로 반영되었는지 검증하세요.

## 프로퍼티 정의

- **이름**: isVisible
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local cursor = this.serviceApi.inputService.cursor
    this.scriptObject:Log("cursor visible = " .. tostring(cursor.isVisible))
end
```
