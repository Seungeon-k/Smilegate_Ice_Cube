---
title: nickname
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Properties/Player_nickname
source_path: LuaScript/VObjects/PlayerVo/Properties/Player_nickname.html
last_updated: "2026.04.06 오후 03:36"
---

# nickname

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`nickname`은(는) 플레이어의 표시 이름을 담는 `string` 값입니다. UI 레이블, 채팅, 랭킹 표시 구간에서 직접 사용합니다. 식별 키로 활용할 때는 `id`나 `userId`와 함께 사용해 충돌을 방지해야 합니다.  

`nickname` 값은 식별 및 검색 기준으로 쓰이므로, 저장/동기화 데이터와 동일한 규칙으로 관리해야 참조 불일치를 줄일 수 있습니다.  

멀티플레이에서는 `nickname`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: nickname
- **타입**: string
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.nickname
    this.scriptObject:Log(tostring(value))
end
```
