---
title: Destroy
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject/Methods/WorldObject_Destroy_WorldGameObjectVo
source_path: LuaScript/VObjects/WorldObject/Methods/WorldObject_Destroy_WorldGameObjectVo.html
last_updated: "2026.04.06 오후 03:37"
---

# Destroy

## 객체

> [WorldObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject)

## 설명

이 함수는 [WorldObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject)를 씬에서 제거합니다.

## 함수

Destroy(targetObject)

### 매개변수

| 형식 | 파라미터 | 설명 |
| --- | --- | --- |
| WorldObject | targetObject | 제거할 오브젝트입니다. |

### 반환값

| 형식 | 설명 |
| --- | --- |
| void | 반환값 없음 |

## 예제 코드

```lua
local obj = parent:Find("Test")
obj:Destroy()
```
