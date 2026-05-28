---
title: id
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Properties/Player_id
source_path: LuaScript/VObjects/PlayerVo/Properties/Player_id.html
last_updated: "2026.04.06 오후 03:36"
---

# id

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`id`은(는) 객체를 식별하기 위한 `number` 값입니다. 중복 체크, 조회 키, 로그 추적의 기준으로 사용합니다. 표시용 문자열과는 분리해 불변 식별값으로 운용하는 구성이 안정적입니다.  

`id` 값은 식별 및 검색 기준으로 쓰이므로, 저장/동기화 데이터와 동일한 규칙으로 관리해야 참조 불일치를 줄일 수 있습니다.  

멀티플레이에서는 `id`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: id
- **타입**: number
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.id
    this.scriptObject:Log(tostring(value))
end
```
