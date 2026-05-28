---
title: hasMotionCurves
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasMotionCurves
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasMotionCurves.html
last_updated: "2026.04.06 오후 03:20"
---

# hasMotionCurves

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

hasMotionCurves는 해당 AnimationClip에 트랜스폼 기반의 모션 곡선(Motion Curves) 이 포함되어 있는지를 나타내는 읽기 전용 속성입니다.  

여기서 모션 곡선이란 오브젝트의 Position, Rotation, Scale 등의 변화를 시간에 따라 표현한 키프레임 데이터를 의미합니다.

이 값이 true라면 애니메이션 클립에 실제 움직임 데이터가 존재하며, 재생 시 오브젝트의 위치나 회전이 변하게 됩니다.  

false라면 해당 클립에는 트랜스폼 변화가 없으며, 다른 파라미터 곡선(예: 머슬이나 플로트 값 등)만 있을 수 있습니다.

## 프로퍼티 정의

- **이름**: `hasMotionCurves`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

-- 모션 곡선 존재 여부 확인
if clip.hasMotionCurves then
    print("이 애니메이션 클립에는 위치/회전 등의 모션 곡선이 존재합니다.")
else
    print("이 애니메이션 클립에는 모션 곡선이 없습니다.")
end
```
