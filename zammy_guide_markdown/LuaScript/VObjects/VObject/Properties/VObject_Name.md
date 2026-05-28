---
title: name
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject/Properties/VObject_Name
source_path: LuaScript/VObjects/VObject/Properties/VObject_Name.html
last_updated: "2026.04.06 오후 03:37"
---

# name

## 객체

> [VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)

## 설명

하이어라키에서 지정된 이름입니다.

## 프로퍼티 정의

- **이름**: `name`
- **타입**: `string`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
-- 특정 영역에 들어온 오브젝트의 이름을 출력하는 예제

function this.OnTriggerEnter(collider)
    script:Log("Trigger Enter")
    script:Log(collider.vObject.name)
end
```
