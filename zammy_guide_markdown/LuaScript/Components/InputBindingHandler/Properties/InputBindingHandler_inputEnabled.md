---
title: inputEnabled
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/InputBindingHandler/Properties/InputBindingHandler_inputEnabled
source_path: LuaScript/Components/InputBindingHandler/Properties/InputBindingHandler_inputEnabled.html
last_updated: "2026.04.06 오후 02:53"
---

# inputEnabled

## 객체

> [InputBindingHandler](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/InputBindingHandler)

## 설명

입력 이벤트 연동 기능의 활성화 여부를 나타냅니다.  

true이면 UI 입력이 InputSetting과 연동되어 시스템 및 Lua로 전달되며, false이면 입력 이벤트 연동이 중지됩니다.

## 프로퍼티 정의

- **이름**: `inputEnabled`
- **타입**: `bool`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
inputBinding = actionButton.root:GetComponent('InputBindingHandler')
inputBinding.inputEnabled = true
```
