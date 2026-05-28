---
title: humanMotion
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_humanMotion
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_humanMotion.html
last_updated: "2026.04.06 오후 03:20"
---

# humanMotion

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

humanMotion은 해당 AnimationClip이 휴머노이드 리깅(Humanoid Rig) 기반으로 만들어진 애니메이션인지 여부를 나타내는 읽기 전용 속성입니다.  

이 값이 true라면 클립이 휴머노이드 아바타에 매핑되어 재생될 수 있으며, 리타게팅(Retargeting) 기능을 통해 다른 휴머노이드 캐릭터에도 재활용할 수 있습니다.

반대로 false라면 이 클립은 Generic 또는 Legacy 리깅 기반이며, 휴머노이드 아바타에 바로 적용할 수 없습니다.

## 프로퍼티 정의

- **이름**: `humanMotion`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

if clip.humanMotion then
    print("이 클립은 휴머노이드 리깅 기반입니다.")
else
    print("이 클립은 휴머노이드 리깅 기반이 아닙니다.")
end
```
