---
title: SetTargetOffset
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/TargetTracker/Methods/TargetTracker_SetTargetOffset_TargetTrackerVo_Vector3
source_path: LuaScript/VObjects/TargetTracker/Methods/TargetTracker_SetTargetOffset_TargetTrackerVo_Vector3.html
last_updated: "2026.04.06 오후 03:36"
---

# SetTargetOffset

## 객체

> [TargetTracker](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/TargetTracker)

## 설명

SetTargetOffset(offset)은 추적 마커의 기준 위치를 대상 기준으로 보정합니다.  

동일 대상이라도 UI 종류에 따라 다른 위치가 필요하므로 오프셋을 분리 관리하면 재사용성이 높아집니다.  

카메라 거리와 시야각에 따라 가시성이 바뀌므로 실제 플레이 화면에서 값 튜닝을 반복하는 것이 좋습니다.

## 함수

SetTargetOffset(offset)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| Vector3 | offset | 대상 기준 표시 위치 보정값입니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.UseNameplateOffset()
    this.scriptObject:SetTargetOffset(Vector3.one)
end
```
