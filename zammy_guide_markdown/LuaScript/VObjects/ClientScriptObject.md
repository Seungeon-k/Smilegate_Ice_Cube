---
title: ClientScriptObject
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ClientScriptObject
source_path: LuaScript/VObjects/ClientScriptObject.html
last_updated: "2026.04.06 오후 03:33"
---

# ClientScriptObject

## 모듈

> VFramework

## 개요

`ClientScriptObject`는 [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)를 상속받아  

**클라이언트 환경에서만 동작하며, 네트워크 동기화를 수행하지 않는 스크립트 오브젝트**입니다.

이 오브젝트는 로컬 전용 로직(예: 이펙트 제어, UI 처리, 입력 반응 등)을 처리하기 위해 사용됩니다.  

서버와의 동기화 없이 **클라이언트 단독으로 동작**하므로,  

시각 효과나 UI 관련 로직 등을 구현할 때 적합합니다.

Lua 스크립트에 `OnStart`, `OnUpdate`, `OnTriggerEnter` 등의 함수를 정의해두면,  

클라이언트 환경에서 해당 이벤트가 발생할 때 자동으로 호출됩니다.

---

## 메서드

| 메서드명 | 설명 | 반환값 |
| --- | --- | --- |
| *(없음)* | `ClientScriptObject`는 [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)의 메서드를 그대로 사용합니다. | - |

---

## 예제 코드

```lua
-- ClientScriptObject에 설정된 Lua 스크립트 예제
function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject

    script:Log("🎮 ClientScriptObject started — local-only logic running.")

    -- 월드에서 이름으로 이펙트 오브젝트 검색
    local world = serviceApi.world
    local effect = world:GetVObject("SpawnEffect")

    if effect ~= nil then
        script:Log("✨ Found effect object: " .. effect.name)
        effect:SetActive(true)
    else
        script:Log("❌ Effect object not found in world.")
    end
end

function this.OnTriggerEnter(collider)
    local character = collider.vObject:Cast("Character")
    if character == nil then
        return
    end

    script:Log("💫 Player entered trigger area (client-side only).")
end

<font color="#808080">*이 콘텐츠는 AI의 도움을 받아 작성 되었으며, 오류가 있을 수 있습니다. </font>
```
