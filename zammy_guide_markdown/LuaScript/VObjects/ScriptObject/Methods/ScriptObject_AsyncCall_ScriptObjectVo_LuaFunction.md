---
title: AsyncCall
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject/Methods/ScriptObject_AsyncCall_ScriptObjectVo_LuaFunction
source_path: LuaScript/VObjects/ScriptObject/Methods/ScriptObject_AsyncCall_ScriptObjectVo_LuaFunction.html
last_updated: "2026.04.06 오후 03:36"
---

# AsyncCall

## 객체

> ScriptObject

## 설명

`AsyncCall`은 콜백을 비동기 큐에 등록해 다음 실행 시점에 호출합니다. 콜백 캡처 변수 수명주기와 재진입 조건을 함께 관리해야 안정적입니다.  

`AsyncCall`은 즉시 실행이 아닌 지연 호출이므로, 호출 직후 의존 로직을 두지 말고 콜백 내부에서 후속 처리를 이어가야 합니다.  

`AsyncCall`를 여러 스크립트가 동시에 호출하면 결과가 덮어써질 수 있으므로, 호출 주체를 명확히 분리해 관리하세요.

## 함수

AsyncCall(luaFunction)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| LuaFunction | luaFunction | luaFunction는 완료 결과를 받는 콜백입니다. code/message 또는 결과 데이터를 확인해 다음 흐름을 제어합니다. |

### 반환값

`LuaAsyncHandle` 결과를 반환합니다. 반환 객체의 유효 상태를 확인한 뒤 후속 처리에 사용하세요.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    target:AsyncCall(function(...) end)
end
```
