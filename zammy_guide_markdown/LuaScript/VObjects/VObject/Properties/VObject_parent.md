---
title: parent
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject/Properties/VObject_parent
source_path: LuaScript/VObjects/VObject/Properties/VObject_parent.html
last_updated: "2026.04.06 오후 03:37"
---

# parent

## 객체

> [VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)

## 설명

하이어라키상의 부모 오브젝트입니다.

## 프로퍼티 정의

- **이름**: `parent`
- **타입**: `VObjectBase`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
-- 스크트의 부모 오브젝트 하위의 다른 오브젝트를 찾아서 해당 위치로 캐릭터를 이동 시키는 예제

function this.MoveCharacter()
    local serviceApi = this.serviceApi
    local localPlayer = serviceApi.playerService.localPlayer
    local playerPosition = script.parent:Find('PlayerPosition').transform
    localPlayer.character.transform.position = playerPosition.position
    localPlayer.character.transform.rotation = playerPosition.rotation
end
```
