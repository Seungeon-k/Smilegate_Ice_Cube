---
title: GetComponentsInChildren
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponentsInChildren_WorldGameObjectVo_string
source_path: LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponentsInChildren_WorldGameObjectVo_string.html
last_updated: "2026.04.06 오후 03:38"
---

# GetComponentsInChildren

## 객체

> [WorldObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject)

## 설명

이 함수는 현재 오브젝트와 모든 자식 오브젝트에서  

지정된 타입의 컴포넌트를 검색하여 **LuaTable** 형태로 반환합니다.

## 함수

GetComponentsInChildren(typeName)

### 매개변수

| 형식 | 파라미터 | 설명 |
| --- | --- | --- |
| string | typeName | 검색할 컴포넌트의 타입 이름입니다. |

### LuaTable 데이터 타입

- 반환 테이블: Component[] (자식 포함, 지정 타입명과 일치하는 컴포넌트)

### 반환값

| 형식 | 설명 |
| --- | --- |
| LuaTable(Component) | 모든 자식에서 찾은 컴포넌트 리스트(LuaTable)를 반환합니다. |

## 예제 코드

```lua
local colliders = root:GetComponentsInChildren("Collider")

for i = 1, #colliders do
    local col = colliders[i]
    print("Child collider:", col)
end

print("총 Collider 개수:", #colliders)
```
