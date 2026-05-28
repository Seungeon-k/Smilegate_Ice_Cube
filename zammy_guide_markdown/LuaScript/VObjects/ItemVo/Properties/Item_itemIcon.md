---
title: itemIcon
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Properties/Item_itemIcon
source_path: LuaScript/VObjects/ItemVo/Properties/Item_itemIcon.html
last_updated: "2026.04.06 오후 03:34"
---

# itemIcon

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

itemIcon은 아이템을 UI에 시각적으로 표시하기 위해 사용되는 아이콘 이미지([Sprite](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/Sprite)) 를 나타내는 프로퍼티입니다.  
  

이 값은 인벤토리, 단축바(Hotbar), 퀵 슬롯, 툴팁 등 다양한 UI 요소에서 아이템을 식별하거나 꾸미는 데 활용됩니다.  

게임 데이터나 에셋에 의해 사전에 설정되며, 스크립트로 직접 수정할 수 없습니다.

## 프로퍼티 정의

- **이름**: `itemIcon`
- **타입**: `Sprite`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
actionButtons.EnableActionButton(slot, item.itemIcon, item.amount, item.coolTime)
```

## 참고 사항

UI 시스템(예: 인벤토리, 퀵 슬롯, 상점 등)과 연계하여 사용자가 직관적으로 아이템을 식별할 수 있게 합니다.
