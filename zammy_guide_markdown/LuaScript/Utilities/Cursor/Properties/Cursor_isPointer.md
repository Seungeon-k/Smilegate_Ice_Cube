---
title: isPointer
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Properties/Cursor_isPointer
source_path: LuaScript/Utilities/Cursor/Properties/Cursor_isPointer.html
last_updated: "2026.04.06 오후 03:30"
---

# isPointer

## 객체

> Cursor

## 설명

`isPointer`는 현재 입력 모드가 포인터 중심 상호작용(UI 클릭/드래그)에 맞춰져 있는지를 나타냅니다.  

값이 `true`일 때는 포커스 이동과 클릭 이벤트를 우선 처리하고, `false`일 때는 게임플레이 입력을 우선 처리하도록 입력 분기를 나누는 데 사용합니다.  

씬 전환이나 UI 스택 변경 시점에 값이 바뀔 수 있으므로, 입력 처리 루프에서 매 프레임 캐시를 갱신하거나 이벤트 기반으로 상태를 동기화하세요.

## 프로퍼티 정의

- **이름**: isPointer
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local cursor = this.serviceApi.inputService.cursor
    local pointerMode = cursor.isPointer
    this.scriptObject:Log("pointer mode = " .. tostring(pointerMode))
end
```
