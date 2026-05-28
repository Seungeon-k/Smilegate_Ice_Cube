---
title: SetTargetObject
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/TargetTracker/Methods/TargetTracker_SetTargetObject_TargetTrackerVo_VObject
source_path: LuaScript/VObjects/TargetTracker/Methods/TargetTracker_SetTargetObject_TargetTrackerVo_VObject.html
last_updated: "2026.04.06 오후 03:36"
---

# SetTargetObject

## 객체

> [TargetTracker](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/TargetTracker)

## 설명

SetTargetObject(vo)는 추적 대상이 되는 VObject를 설정합니다.  

라운드 시작, 타깃 교체, 보스 페이즈 전환처럼 추적 대상이 바뀌는 시점에 호출합니다.  

nil 또는 이미 제거된 객체를 전달하면 추적 표시가 비정상 동작할 수 있으므로 유효성 검사를 먼저 수행하는 것이 좋습니다.

## 함수

SetTargetObject(vo)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| VObject | vo | 추적할 대상 객체입니다. 월드에 존재하고 표시 대상이 되는 객체를 전달합니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.BindTarget(target)
    if target == nil then
        return
    end

    this.scriptObject:SetTargetObject(target)
end
```
