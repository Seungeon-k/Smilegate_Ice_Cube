---
title: SetCaptured
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Methods/Cursor_SetCaptured_VCursor
source_path: LuaScript/Utilities/Cursor/Methods/Cursor_SetCaptured_VCursor.html
last_updated: "2026.04.06 오후 03:30"
---

# SetCaptured

## 객체

> Cursor

## 설명

SetCaptured는 커서를 캡처 상태로 전환합니다.  

호출하면 커서가 화면 중앙에 고정되고, 포인터 이동 대신 마우스 델타가 시점/조작 입력으로 전달됩니다.  

FPS 시점 제어처럼 포인터 노출보다 플레이 입력이 우선인 구간에서 사용하며, 보통 커서 표시 해제와 함께 적용합니다.  

UI에서 플레이로 복귀할 때 입력 게이트 복원 순서와 함께 호출하면 의도치 않은 조작 유입을 줄일 수 있습니다.

## 함수

SetCaptured()

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| 없음 | - | 입력 인자 없이 `Captured` 상태를 현재 컨텍스트 기준으로 설정합니다. 호출 전에 대상 객체 초기화와 권한 상태를 점검해 동기화 오차를 줄이세요. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local inputService = this.serviceApi.inputService
    local cursor = inputService.cursor
    cursor:SetCaptured()
end
```
