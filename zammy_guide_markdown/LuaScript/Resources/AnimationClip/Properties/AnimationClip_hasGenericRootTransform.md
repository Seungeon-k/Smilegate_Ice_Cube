---
title: hasGenericRootTransform
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasGenericRootTransform
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasGenericRootTransform.html
last_updated: "2026.04.06 오후 03:20"
---

# hasGenericRootTransform

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

hasGenericRootTransform은 해당 AnimationClip에 루트 트랜스폼(Root Transform) 데이터가 포함되어 있는지를 나타내는 읽기 전용 속성입니다.  

여기서 “루트 트랜스폼”이란 애니메이션 클립에서 캐릭터의 전체 이동(Position)이나 회전(Rotation) 을 제어하는 최상위 트랜스폼을 의미합니다.

이 속성이 true인 경우, 애니메이션 클립에 루트 모션 데이터가 포함되어 있어 [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)의 루트 모션 시스템을 통해 실제 위치 이동에 반영할 수 있습니다.  

반면 false라면 해당 클립은 루트 트랜스폼 데이터를 가지지 않으며, 루트 모션을 통해 이동이 일어나지 않습니다.

## 프로퍼티 정의

- **이름**: `hasGenericRootTransform`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

-- 루트 트랜스폼 여부 확인
if clip.hasGenericRootTransform then
    print("이 클립은 루트 트랜스폼 데이터를 포함하고 있습니다.")
else
    print("이 클립은 루트 트랜스폼 데이터를 포함하지 않습니다.")
end
```
