---
title: SetVector2Value
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/InputBindingHandler/Methods/InputBindingHandler_SetVector2Value_InputBindingHandler
source_path: LuaScript/Components/InputBindingHandler/Methods/InputBindingHandler_SetVector2Value_InputBindingHandler.html
last_updated: "2026.04.06 오후 02:53"
---

# SetVector2Value

## 객체

> [InputBindingHandler](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/InputBindingHandler)

## 설명

SetVector2Value는 InputBindingHandler에 연결된 Binding Input의 값을 Vector2로 설정합니다.  

조이스틱, 이동 패드처럼 Vector2 형태의 입력을 시스템이나 Lua에서 사용할 수 있도록 입력 값을 기록(반영) 할 때 사용합니다.

## 함수

SetVector2Value(value)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Vector2](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2) | value | Binding Input 값에 설정할 값 |

### 반환값

없음

## 예제 코드

```lua
inputBindingHandler = joystick:GetComponent('InputBindingHandler')
inputBindingHandler:SetVector2Value(Vector2(0, 0))
```
