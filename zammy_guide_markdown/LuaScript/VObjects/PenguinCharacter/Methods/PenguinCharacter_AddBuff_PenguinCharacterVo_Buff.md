---
title: AddBuff
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddBuff_PenguinCharacterVo_Buff
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddBuff_PenguinCharacterVo_Buff.html
last_updated: "2026.04.06 오후 03:34"
---

# AddBuff

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

AddBuff는 대상 [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)에 지정한 [Buff](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo)를 적용(추가) 합니다.  

버프 적용이 완료되면 버프 시스템 규칙에 따라 신규 추가, 상충 처리(교체/제거 후 적용) 등이 발생할 수 있습니다.

## 함수

AddBuff(buff)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Buff](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo) | buff | 캐릭터에 적용할 버프입니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Buff](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/BuffVo) | 캐릭터에 적용된(또는 상충 처리 이후 활성 상태가 된) 버프 객체를 반환합니다. |

## 예제 코드

```lua
this.buff = __EX_VARIABLE__.vobject()

function this.OnStart()
    scriptObject = this.scriptObject

    myItem = scriptObject.parent

    if myItem then
        if myItem.OnAttackBegin then
            myItem.OnAttackBegin:AddListener(this.OnAttackBegin)
        end

    end
end

function this.OnAttackBegin(item)

    scriptObject:Log("OnAttackBegin")

    local myOwner = item:GetOwnerCharacter()

    -- add buff
    local myBuff = myOwner:AddBuff(this.buff)

end
```
