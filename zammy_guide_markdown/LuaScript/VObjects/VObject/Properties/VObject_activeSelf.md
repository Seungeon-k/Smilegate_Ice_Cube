---
title: activeSelf
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject/Properties/VObject_activeSelf
source_path: LuaScript/VObjects/VObject/Properties/VObject_activeSelf.html
last_updated: "2026.04.06 오후 03:37"
---

# activeSelf

## 객체

> [VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)

## 설명

오브젝트의 활성화 여부를 나타냅니다.

## 프로퍼티 정의

- **이름**: `activeSelf`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
-- UI서비스에서 특정 UI오브젝트를 찾아서 캐싱 해놓고 해당 오브젝트를 토글 하는 함수 예제

local actionButton

function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject

    actionButton = serviceApi.uiService:GetChildUI('PlayerControlButton/ActionButton')
end

function this.ToggleActionButton()
    local toggle = not actionButton.activeSelf
    actionButton:SetActive(toggle)
end
```
