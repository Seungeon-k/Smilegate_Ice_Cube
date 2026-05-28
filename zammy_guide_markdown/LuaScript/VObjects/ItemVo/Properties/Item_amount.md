---
title: amount
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Properties/Item_amount
source_path: LuaScript/VObjects/ItemVo/Properties/Item_amount.html
last_updated: "2026.04.06 오후 03:34"
---

# amount

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

amount는 해당 아이템의 현재 수량을 나타내는 프로퍼티입니다.  
  

이 값은 주로 소비 아이템(예: 포션, 탄약 등)의 남은 개수를 표현하며, 장비 아이템(무기, 방어구 등)에서는 사용 가능 휫수 등을 나타낼 수 있습니다.  
  

게임 진행 중 아이템을 사용하거나 획득함에 따라 값이 변경될 수 있습니다.

## 프로퍼티 정의

- **이름**: `amount`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
-- 아이템 수량 확인
local potion = somePotionItem


-- 아이템 수량 감소
potion.amount = potion.amount - 1


-- 아이템 수량 증가 (획득 시)
potion.amount = potion.amount + 5
```
