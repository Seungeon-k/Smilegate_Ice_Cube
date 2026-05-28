---
title: legacy
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_legacy
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_legacy.html
last_updated: "2026.04.06 오후 03:20"
---

# legacy

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

legacy는 해당 [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)이 레거시 애니메이션 시스템(Legacy Animation System) 에 속하는지 여부를 나타내는 읽기 전용 속성입니다.  

이 값이 true라면 해당 애니메이션 클립은 오래된 Animation 컴포넌트 기반의 재생 방식을 사용하며,  

false일 경우 현대적인 [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)(Mecanim) 시스템에서 사용되는 클립입니다.

레거시 애니메이션은 단순한 구조로 빠르고 직관적인 제어가 가능하지만, 상태 머신이나 리타게팅과 같은 고급 기능을 지원하지 않습니다.

## 프로퍼티 정의

- **이름**: `legacy`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

if clip.legacy then
    print("이 클립은 Legacy 애니메이션 시스템을 사용합니다.")
else
    print("이 클립은 Mecanim(Animator) 시스템을 사용합니다.")
end
```
