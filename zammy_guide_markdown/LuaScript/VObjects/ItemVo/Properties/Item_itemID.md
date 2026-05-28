---
title: itemId
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Properties/Item_itemID
source_path: LuaScript/VObjects/ItemVo/Properties/Item_itemID.html
last_updated: "2026.04.06 오후 03:34"
---

# itemId

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

itemId는 아이템을 고유하게 식별하기 위한 문자열 ID입니다.  

이 값은 아이템의 종류와 속성을 구분하는 핵심 키로, 아이템 인벤토리 시스템에서 특정 아이템을 검색, 비교, 관리할 때 사용됩니다.  

이 값은 게임 개발 단계에서 미리 정의되며, 런타임 중 변경할 수 없습니다.

## 프로퍼티 정의

- **이름**: `itemId`
- **타입**: `string`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
-- 특정 ID를 가진 아이템 비교 예제
if item.itemId == "health_potion" then
    -- 이 아이템은 회복 포션입니다.
end
```

## 참고 사항

itemId는 아이템의 고유성을 보장하는 식별자입니다.  
  

인벤토리, 장착 등 다양한 로직에서 이 값을 기준으로 처리됩니다.  
  

동일한 itemId를 가진 아이템은 동일한 종류로 간주됩니다.
