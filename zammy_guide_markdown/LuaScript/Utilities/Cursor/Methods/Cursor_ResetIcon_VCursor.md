---
title: ResetIcon
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Methods/Cursor_ResetIcon_VCursor
source_path: LuaScript/Utilities/Cursor/Methods/Cursor_ResetIcon_VCursor.html
last_updated: "2026.04.06 오후 03:30"
---

# ResetIcon

## 객체

> Cursor

## 설명

ResetIcon 메서드는 관련 상태를 초기화하거나 정리합니다.  

`ResetIcon` 호출 직후 기준 상태가 바뀌므로, 이어지는 입력/물리/애니메이션 처리 순서를 재정렬해야 예상치 못한 되돌림을 막을 수 있습니다.  

`ResetIcon`를 여러 스크립트가 동시에 호출하면 결과가 덮어써질 수 있으므로, 호출 주체를 명확히 분리해 관리하세요.

## 함수

ResetIcon()

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| 없음 | - | 입력 인자 없이 `Icon` 상태를 기본값으로 복원합니다. 동일 프레임 중복 호출 시 값이 다시 덮일 수 있으니 실행 순서를 고정하세요. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    target:ResetIcon()
end
```
