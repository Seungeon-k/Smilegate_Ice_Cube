---
title: GetComponentInChildren
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentInChildren_UIGameObjectVo_string
source_path: LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentInChildren_UIGameObjectVo_string.html
last_updated: "2026.04.06 오후 03:37"
---

# GetComponentInChildren

## 객체

> [UIObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/UIObject)

## 설명

이 함수는 현재 오브젝트와 자식 오브젝트들을 포함하여 지정된 타입의 첫 번째 컴포넌트를 검색합니다.

## 함수

GetComponentInChildren(typeName)

### 매개변수

| 형식 | 파라미터 | 설명 |
| --- | --- | --- |
| string | typeName | 검색할 컴포넌트의 타입 이름입니다. |

### 반환값

| 형식 | 설명 |
| --- | --- |
| Component | 발견된 첫 번째 컴포넌트를 반환하거나 nil을 반환합니다. |

## 예제 코드

```lua
local renderer = parent:GetComponentInChildren("Renderer")
if renderer then
    renderer:SetVisible(false)
end
```
