---
title: OnAttackBegin
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Events/Item_OnAttackBegin
source_path: LuaScript/VObjects/ItemVo/Events/Item_OnAttackBegin.html
last_updated: "2026.04.06 오후 03:33"
---

# OnAttackBegin

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

OnAttackBegin은 아이템 사용 시 공격 동작이 시작되는 시점에 호출되는 이벤트입니다.  

이 이벤트는 공격 애니메이션 재생, 준비 동작(윈드업), 타이밍 제어 등의 로직을 처리하는 데 주로 활용됩니다.  

공격 판정이 실제로 발생하는 시점과는 다르며, [OnAttack](Item_OnAttack.md) 이벤트보다 먼저 호출됩니다.

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | item | 어떤 아이템에서 이벤트가 발생했는지를 나타냅니다. |

## 사용 예제

```lua
sword.OnAttackBegin:AddListener(function(item)

    PlaySound("SwordDraw")
end)
```

## 참고 사항

OnAttackBegin은 공격의 준비 단계를 처리하는 데 유용합니다.  
  

공격 판정이 발생하는 시점은 [OnAttack](Item_OnAttack.md) 이벤트에서 처리됩니다.
