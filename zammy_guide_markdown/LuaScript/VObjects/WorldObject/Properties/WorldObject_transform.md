---
title: transform
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/WorldObject/Properties/WorldObject_transform
source_path: LuaScript/VObjects/WorldObject/Properties/WorldObject_transform.html
last_updated: "2026.04.06 오후 03:38"
---

# transform

## 객체

> WorldObject

## 설명

`transform`은(는) 위치, 회전, 스케일에 접근하기 위한 `any` 참조입니다. 이동/정렬/부착 계산의 기준 지점으로 사용됩니다. 구조 변경 구간에서는 최신 참조 유효성을 다시 확인하는 것이 안전합니다.  

`transform` 값은 좌표계(로컬/월드)와 부모 계층 상태에 따라 결과가 달라질 수 있으므로, 연산 직전에 최신 값을 다시 읽어 사용하는 것이 안전합니다.  

멀티플레이에서는 `transform`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: transform
- **타입**: any
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.transform
    this.scriptObject:Log(tostring(value))
end
```
