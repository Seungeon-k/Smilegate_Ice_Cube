---
title: GetComponent
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/UIObject/Methods/UIObject_GetComponent_UIGameObjectVo_string
source_path: LuaScript/VObjects/UIObject/Methods/UIObject_GetComponent_UIGameObjectVo_string.html
last_updated: "2026.04.06 오후 03:37"
---

# GetComponent

## 객체

> [UIObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/UIObject)

## 설명

이 함수는 [UIObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/UIObject)에 추가된 특정 타입의 컴포넌트(Component)를 검색하고 반환합니다.  

입력된 문자열(typeName)은 검색할 컴포넌트의 타입 이름을 나타내며,  

해당 타입의 컴포넌트가 오브젝트에 존재하지 않을 경우 nil을 반환합니다.

## 함수

GetComponent(typeName)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | typeName | 검색할 컴포넌트의 타입 이름입니다. 예를 들어 “Renderer”, “Collider”, “RigidBody” 와 같이 입력합니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| Component | 검색된 컴포넌트 객체를 반환합니다. 해당 타입의 컴포넌트가 존재하지 않으면 nil을 반환합니다. |

## 예제 코드

```lua
local crate = someObject

-- Renderer 컴포넌트 가져오기
local renderer = crate:GetComponent("Renderer")
if renderer ~= nil then
  renderer:SetColor(Color(0.4, 0.8, 1.0))
  print("Renderer 색상 변경 완료")
else
  print("Renderer 컴포넌트를 찾을 수 없습니다.")
end

-- Collider 존재 여부 확인
local collider = crate:GetComponent("Collider")
if collider then
  print("Collider 감지 성공!")
end
```
