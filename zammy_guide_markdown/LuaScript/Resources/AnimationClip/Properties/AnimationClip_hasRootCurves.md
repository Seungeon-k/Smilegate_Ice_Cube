---
title: hasRootCurves
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasRootCurves
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasRootCurves.html
last_updated: "2026.04.06 오후 03:20"
---

# hasRootCurves

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

hasRootCurves는 해당 AnimationClip에 루트 트랜스폼(Root Transform) 에 대한 곡선(Root Curves)이 포함되어 있는지를 나타내는 읽기 전용 속성입니다.  

여기서 “루트 곡선”이란 애니메이션의 루트 본 또는 루트 트랜스폼이 가지는 위치(Position) 및 회전(Rotation) 에 대한 시간 기반 키프레임 데이터를 의미합니다.

이 값이 true인 경우, 해당 애니메이션 클립은 루트 모션(Root Motion)을 통해 실제 오브젝트의 이동이나 회전에 영향을 줄 수 있습니다.  

반대로 false일 경우 루트 트랜스폼에 대한 모션 데이터가 없으며, [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)의 루트 모션 기능을 사용하더라도 이동이 발생하지 않습니다.

## 프로퍼티 정의

- **이름**: `hasRootCurves`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

-- 루트 곡선 존재 여부 확인
if clip.hasRootCurves then
    print("이 애니메이션 클립에는 루트 트랜스폼 곡선이 포함되어 있습니다.")
else
    print("이 애니메이션 클립에는 루트 트랜스폼 곡선이 없습니다.")
end
```
