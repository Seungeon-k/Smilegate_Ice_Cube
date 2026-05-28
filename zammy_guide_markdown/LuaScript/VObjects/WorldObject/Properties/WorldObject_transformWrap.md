---
title: transform
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject/Properties/WorldObject_transformWrap
source_path: LuaScript/VObjects/WorldObject/Properties/WorldObject_transformWrap.html
last_updated: "2026.04.06 오후 03:38"
---

# transform

## 객체

> [WorldObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject)

## 설명

이 프로퍼티는 WorldObject의 공간 정보(위치, 회전, 크기)를 제어하는 핵심 컴포넌트인 [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)을 반환합니다.

## 프로퍼티 정의

- **이름**: `transform`
- **타입**: `Transform`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local obj = someObject

-- 위치 변경
obj.transform.position = Vector3(0, 2, 0)

-- 회전 설정 (Y축 기준 45도 회전)
obj.transform.rotation = Quaternion.Euler(0, 45, 0)

-- 크기 변경
obj.transform.localScale = Vector3(2, 2, 2)
```
