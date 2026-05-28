---
title: OnAttack
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Events/Item_OnAttack
source_path: LuaScript/VObjects/ItemVo/Events/Item_OnAttack.html
last_updated: "2026.04.06 오후 03:33"
---

# OnAttack

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

OnAttack은 아이템 사용 시 공격이 실제로 발동되는 시점에 호출되는 이벤트입니다.  

이 이벤트는 공격 판정, 데미지 적용, 피격 반응 처리, 이펙트 및 사운드 재생 등의 전투 로직과 밀접하게 연관됩니다.  

주로 무기 아이템, 스킬 아이템 등에 활용되며, 다양한 전투 연출 및 효과를 추가하는 데 사용됩니다.

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo) | item | 어떤 아이템에서 이벤트가 발생했는지를 나타냅니다. |

## 사용 예제

```lua
item.OnAttack:AddListener(function(item)
    soundService:Play(this.hitSound)
end)
```

## 참고 사항

OnAttack은 공격 동작이 시작되는 시점이 아니라, 공격 판정이 실제로 발생하는 시점에 호출됩니다.
