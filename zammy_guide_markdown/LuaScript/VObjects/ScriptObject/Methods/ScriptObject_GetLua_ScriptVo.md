---
title: GetLua
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject/Methods/ScriptObject_GetLua_ScriptVo
source_path: LuaScript/VObjects/ScriptObject/Methods/ScriptObject_GetLua_ScriptVo.html
last_updated: "2026.04.06 오후 03:36"
---

# GetLua

## 객체

> [ScriptObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)

## 설명

`GetLua`는 [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)에 연결된 **Lua 스크립트 테이블(`LuaTable`)** 을 반환하는 함수입니다.  

이 테이블은 Lua 스크립트 내에서 정의된 변수, 함수, 이벤트 등을 접근하거나 제어할 때 사용됩니다.

이 메서드를 통해 스크립트의 내부 상태를 직접 조회하거나,  

다른 객체의 스크립트 함수 호출 등의 고급 조작을 수행할 수 있습니다.

---

## 함수

`GetLua(scriptObject)`

---

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject) | `scriptObject` | Lua 스크립트를 포함하고 있는 [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject) 인스턴스입니다. |

---

### LuaTable 데이터 타입

- 반환 테이블: Script Lua Table (스크립트 필드/함수 맵)

### 반환값

| **형식** | **설명** |
| --- | --- |
| `LuaTable` | 해당 [ScriptObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)에 연결된 Lua 테이블 객체를 반환합니다. 스크립트 함수나 변수를 직접 접근할 수 있습니다. |

---

## 예제 코드

```lua
function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject

    -- ScriptObject에서 Lua 테이블을 가져옴
    local luaTable = script:GetLua()

    -- Lua 테이블의 변수를 직접 확인하거나 조작 가능
    if luaTable.health then
        print("Current Health:", luaTable.health)
    end

    -- Lua 테이블에 정의된 함수가 있다면 직접 호출할 수도 있음
    if luaTable.OnCustomAction then
        luaTable.OnCustomAction()
    end

    script:Log("📜 LuaTable accessed successfully.")
end

<font color="#808080">*이 콘텐츠는 AI의 도움을 받아 작성 되었으며, 오류가 있을 수 있습니다. </font>
```
