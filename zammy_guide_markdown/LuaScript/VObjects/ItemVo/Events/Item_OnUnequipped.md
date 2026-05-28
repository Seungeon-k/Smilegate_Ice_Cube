---
title: OnUnequipped
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Events/Item_OnUnequipped
source_path: LuaScript/VObjects/ItemVo/Events/Item_OnUnequipped.html
last_updated: "2026.04.06 오후 03:33"
---

# OnUnequipped

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

OnUnequipped는 아이템이 해제(Unequip) 처리된 직후 호출되는 이벤트/콜백입니다.  

플레이어(또는 장착 가능한 주체)가 특정 Item  

을 장착 상태에서 제거하는 과정이 성공적으로 완료되었을 때 발생합니다

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | item | 어떤 아이템에서 이벤트가 발생했는지를 나타냅니다. |

## 사용 예제

```lua
sword.OnEquipped:AddListener(function(item)

    PlaySound("Unequipped Sound")
end)
```
