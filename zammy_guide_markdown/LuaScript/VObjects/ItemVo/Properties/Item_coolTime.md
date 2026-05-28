---
title: coolTime
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Properties/Item_coolTime
source_path: LuaScript/VObjects/ItemVo/Properties/Item_coolTime.html
last_updated: "2026.04.06 오후 03:34"
---

# coolTime

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

coolTime은 해당 아이템을 사용한 후 다시 사용할 수 있기까지의 대기 시간(초) 을 나타내는 프로퍼티입니다.  

쿨타임이 존재하는 아이템은 사용 직후 일정 시간 동안 재사용이 불가능하며, 전투나 스킬 시스템에서 중요한 제어 요소로 활용됩니다.  

이 값은 읽기 전용이며, 아이템의 설정이나 밸런스 데이터에 의해 사전에 정의됩니다.

## 프로퍼티 정의

- **이름**: `coolTime`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
-- 아이템의 쿨타임
actionButtons.EnableActionButton(slot, item.itemIcon, item.amount, item.coolTime)
```

## 참고 사항

coolTime은 아이템 사용 시 직접적으로 필요 한 곳에 사용해야 합니다. 시스템적으로 자동 적용되는 곳은 없습니다.
