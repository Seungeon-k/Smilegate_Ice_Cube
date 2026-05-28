---
title: hasMotionFloatCurves
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasMotionFloatCurves
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasMotionFloatCurves.html
last_updated: "2026.04.06 오후 03:20"
---

# hasMotionFloatCurves

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

hasMotionFloatCurves는 해당 AnimationClip에 플로트(float) 타입의 모션 곡선(Motion Float Curves) 이 포함되어 있는지를 나타내는 읽기 전용 속성입니다.  

여기서 Motion Float Curve란 트랜스폼(Position, Rotation 등)과는 별도로, 시간에 따라 값이 변하는 수치 파라미터 곡선을 의미합니다.

이 곡선은 주로 다음과 같은 경우에 사용됩니다.

- 
  머슬 애니메이션 (Humanoid 리깅에서 근육 움직임 제어)
- 
  머티리얼이나 셰이더 파라미터 제어
- 
  커스텀 애니메이션 파라미터 (예: BlendShape 값 변화)

즉, 이 속성이 true라면 해당 클립은 단순한 위치 이동뿐 아니라 수치 기반의 상태 변화를 포함하고 있을 가능성이 높습니다.

## 프로퍼티 정의

- **이름**: `hasMotionFloatCurves`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

-- 플로트 곡선 존재 여부 확인
if clip.hasMotionFloatCurves then
    print("이 애니메이션 클립에는 플로트 곡선이 포함되어 있습니다.")
else
    print("이 애니메이션 클립에는 플로트 곡선이 없습니다.")
end
```
