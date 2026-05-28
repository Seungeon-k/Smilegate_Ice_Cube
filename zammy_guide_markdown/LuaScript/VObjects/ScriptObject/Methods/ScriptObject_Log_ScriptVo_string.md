---
title: Log
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject/Methods/ScriptObject_Log_ScriptVo_string
source_path: LuaScript/VObjects/ScriptObject/Methods/ScriptObject_Log_ScriptVo_string.html
last_updated: "2026.04.06 오후 03:36"
---

# Log

## 객체

> [ScriptObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)

## 설명

`Log`는 [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)와 관련된 Lua 스크립트나 실행 중인 이벤트의 상태를  

**콘솔 또는 디버그 로그에 출력**하기 위한 함수입니다.

이 메서드는 Lua 스크립트 실행 중 메시지를 남기거나,  

디버깅용으로 스크립트의 흐름을 추적할 때 사용됩니다.  

출력되는 로그는 `[Lua Script][ScriptObjectName]` 형식으로 표시되어  

어떤 스크립트에서 발생한 메시지인지 쉽게 구분할 수 있습니다.

---

## 함수

`Log(scriptObject, message)`

---

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject) | `scriptObject` | 로그를 남길 [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject) 인스턴스입니다. |
| `string` | `message` | 출력할 메시지 문자열입니다. |

---

### 반환값

없음

---

## 예제 코드

```lua
function this.OnStart()
    script = this.scriptObject

    -- 간단한 디버그 메시지 출력
    script:Log("🧩 ScriptObject started successfully!")

    -- 추가 정보 포함한 로그 출력
    local player = this.serviceApi.world:GetVObject("Player")
    if player then
        script:Log("🎮 Player object found: " .. player.name)
    else
        script:Log("⚠️ Player object not found in world.")
    end
end

<font color="#808080">*이 콘텐츠는 AI의 도움을 받아 작성 되었으며, 오류가 있을 수 있습니다. </font>
```
