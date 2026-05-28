---
title: GetComponents
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponents_WorldGameObjectVo_string
source_path: LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponents_WorldGameObjectVo_string.html
last_updated: "2026.04.06 오후 03:38"
---

# GetComponents

## 객체

> [WorldObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject)

## 설명

이 함수는 [WorldObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject)에 추가된 특정 타입의 모든 컴포넌트를 검색하여 **LuaTable** 형태로 반환합니다.  

존재하지 않을 경우 빈 LuaTable이 반환됩니다.

## 함수

GetComponents(typeName)

### 매개변수

| 형식 | 파라미터 | 설명 |
| --- | --- | --- |
| string | typeName | 검색할 컴포넌트의 타입 이름입니다. |

### LuaTable 데이터 타입

- 반환 테이블: Component[] (지정한 타입명과 일치하는 컴포넌트)

### 반환값

| 형식 | 설명 |
| --- | --- |
| LuaTable(Component) | 검색된 모든 컴포넌트를 담은 LuaTable을 반환합니다. |

## 예제 코드

```lua
local colliders = crate:GetComponents("Collider")

-- LuaTable은 #로 길이를 계산합니다.
for i = 1, #colliders do
    local col = colliders[i]
    print("Collider:", col)
end
```
