---
title: RemoveBuff
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RemoveBuff_PenguinCharacterVo_Buff
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RemoveBuff_PenguinCharacterVo_Buff.html
last_updated: "2026.04.06 오후 03:35"
---

# RemoveBuff

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

RemoveBuff는 대상 [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)에서 지정한 [Buff](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo)  

를 제거(해제) 합니다.

## 함수

RemoveBuff(buff)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Buff](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo) | buff | 캐릭터에서 제거할 버프입니다. 일반적으로 캐릭터에 적용되어 있던 버프를 전달합니다. |

## 예제 코드

```lua
this.LifeTime =  __EX_VARIABLE__.float(2)

local activeBuff = false
local owner
local buffTime  = 0

function this.OnEnable()

    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
    soundService = serviceApi.soundService
    world = serviceApi.world

    if initialed == true then
        return
    end
    initialed = true

    scriptObject.parent.OnAdded:AddListener(this.OnAdded)

    buffTime = 0


end

function this.OnAdded(character, buff)

    owner = character
    activeBuff = true

end

function this.OnUpdate(deltaTime)

    if activeBuff == false then
        return
    end

    buffTime = buffTime + deltaTime

    if buffTime >= this.LifeTime then
        activeBuff = false

        if owner then
            owner:RemoveBuff(scriptObject.parent)
        end
    end

end
```
