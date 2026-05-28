---
title: buttonActionTrigger
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Properties/Item_buttonActionTrigger
source_path: LuaScript/VObjects/ItemVo/Properties/Item_buttonActionTrigger.html
last_updated: "2026.04.06 오후 03:34"
---

# buttonActionTrigger

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

buttonActionTrigger 는 Item이 어떤 버튼 상태일 때 사용 되어 질 것인지 설정된 Item 프로퍼티 입니다.

## 프로퍼티 정의

- **이름**: `buttonActionTrigger`
- **타입**: [`ButtonState`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ButtonState)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function PressButton(slot, buttonState)

    local item = GetSomeItem()

    if item.buttonActionTrigger ~= buttonState then
        return false
    end

    -- do something
end
```
