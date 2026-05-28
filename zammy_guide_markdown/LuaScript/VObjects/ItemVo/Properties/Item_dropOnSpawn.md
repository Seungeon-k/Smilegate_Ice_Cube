---
title: dropOnSpawn
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Properties/Item_dropOnSpawn
source_path: LuaScript/VObjects/ItemVo/Properties/Item_dropOnSpawn.html
last_updated: "2026.04.06 오후 03:34"
---

# dropOnSpawn

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

`dropOnSpawn`은 아이템 생성 시 월드에서 Drop(낙하) 상태로 처리 될 건지 여부를 나타내는 값입니다.  

값이 `true`라도 해당 값을 참조하여 Lua 에서 낙하를 시켜야합니다.  

서버가 스폰을 권한 관리하는 구조에서는 이 값을 서버 기준으로만 결정하는 방식이 안정적입니다.

## 프로퍼티 정의

- **이름**: dropOnSpawn
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.dropOnSpawn
    this.scriptObject:Log(tostring(value))
end
```
