---
title: isActiveInWorld
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Properties/Item_isActiveInWorld
source_path: LuaScript/VObjects/ItemVo/Properties/Item_isActiveInWorld.html
last_updated: "2026.04.06 오후 03:34"
---

# isActiveInWorld

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

`isActiveInWorld`는 아이템이 현재 월드에서 활성 오브젝트로 존재해 상호작용 가능한 상태인지 나타냅니다.  

값이 `false`이면 렌더/충돌/상호작용 처리 중 일부가 비활성일 수 있으므로, 획득 검사와 자동 사용 로직을 실행하기 전에 먼저 확인해야 합니다.  

스폰/디스폰이 빠르게 반복되는 구간에서는 이벤트 기반 갱신과 함께 이 값을 병행 확인해 중복 획득이나 유령 참조를 방지하세요.

## 프로퍼티 정의

- **이름**: isActiveInWorld
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.isActiveInWorld
    this.scriptObject:Log(tostring(value))
end
```
