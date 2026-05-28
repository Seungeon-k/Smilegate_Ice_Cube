---
title: ServerScriptObject
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ServerScriptObject
source_path: LuaScript/VObjects/ServerScriptObject.html
last_updated: "2026.04.06 오후 03:36"
---

# ServerScriptObject

## 모듈

> VFramework

## 개요

`ServerScriptObject`는 [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)를 상속받아  

**서버 환경에서 실행되며, 모든 행위가 네트워크를 통해 동기화되는 스크립트 오브젝트**입니다.

서버에서 실행되는 로직은 `ServerScriptObject`를 통해 수행되며,  

이 객체에서 발생한 변수 변경, 이벤트 호출, 상태 변화 등은  

자동으로 클라이언트와 **네트워크를 통해 동기화**됩니다.

즉, 서버는 게임의 **권위(authority)** 로서 실제 상태를 결정하며,  

`ServerScriptObject`는 그 상태를 관리하고 클라이언트에 반영하는 역할을 합니다.  

Lua 스크립트에서 `OnStart`, `OnUpdate`, `OnTriggerEnter` 등의 함수를 정의하면,  

서버 사이드에서 해당 이벤트가 발생할 때 자동으로 호출됩니다.

---

## 메서드

| 메서드명 | 설명 | 반환값 |
| --- | --- | --- |
| *(없음)* | `ServerScriptObject`는 [`ScriptObject`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ScriptObject)의 메서드를 그대로 사용합니다. | - |

---

## 예제 코드

```lua
local this = __CREATOR__.new()

local serviceApi
local script

-- 카운트다운 시간 변수 (초)
this.CountdownTime = 5

-- 이벤트 정의
local onCountdownStart = nil
local onGameStart = nil
local onLocalPlayerReady = nil
-- 내부 상태
local countdown = 0
local isCounting = false
local elapsed = 0

function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject
    script:Log("GameStart Ready")
    onCountdownStart = script.OnCountdownStart
    onGameStart = script.OnGameStart
    onLocalPlayerReady = script.OnLocalPlayerReady

    -- Room.OnFinishMatch 이벤트 구독
    serviceApi.room.OnFinishMatch:AddListener(this.OnFinishMatchHandler)

    -- PlayerService.OnPlayerReady 이벤트 구독
    serviceApi.playerService.OnPlayerReady:AddListener(this.OnPlayerReadyHandler)
end

-- FinishMatch 발생 시 카운트다운 시작
function this.OnFinishMatchHandler()
    countdown = this.CountdownTime
    isCounting = true
    elapsed = 0

    -- 카운트다운 시작 이벤트 호출
    script:Log("Countdown started for " .. tostring(countdown) .. " seconds")
    if onCountdownStart ~= nil then
        onCountdownStart:Call(countdown)
    end
end

-- PlayerReady 발생 시 로컬 플레이어인지 확인
function this.OnPlayerReadyHandler(player)
    if player == nil or player.id == nil then
        return
    end

    local id = player.id
    if player.isLocalPlayer then
        script:Log("Local Player Ready: " .. tostring(id))
        if onLocalPlayerReady ~= nil then
            onLocalPlayerReady:Call(id)
        end
    else
        script:Log("Remote Player Ready: " .. tostring(id))
    end
end

-- 매 프레임 호출
function this.Update(deltaTime)
    if not isCounting then return end

    elapsed = elapsed + deltaTime
    if elapsed >= countdown then
        isCounting = false
        script:Log("Countdown finished, Game Start!")
        if onGameStart ~= nil then
            onGameStart:Call()
        end
    end
end

<font color="#808080">*이 콘텐츠는 AI의 도움을 받아 작성 되었으며, 오류가 있을 수 있습니다. </font>
```
