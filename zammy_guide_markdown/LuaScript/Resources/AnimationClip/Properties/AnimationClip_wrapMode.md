---
title: wrapMode
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_wrapMode
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_wrapMode.html
last_updated: "2026.04.06 오후 03:21"
---

# wrapMode

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

wrapMode는 애니메이션이 끝났을 때 어떤 방식으로 동작할 것인지를 정의하는 속성으로,  

애니메이션의 재생 방식(Once, Loop, PingPong 등)을 제어하는 WrapMode  

열거형 값을 반환합니다.

이 값은 애니메이션이 재생 완료 후:

- 
  반복할지,
- 
  멈출지,
- 
  마지막 프레임에 고정할지,
- 
  또는 앞뒤로 왕복할지를 결정합니다.

이 값은 런타임에서 읽기 전용이며, 설정은 에디터에서 애니메이션 임포트 옵션 또는 코드로 AnimationState를 통해 변경할 수 있습니다.

## 프로퍼티 정의

- **이름**: `wrapMode`
- **타입**: [`WrapMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/WrapMode)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

local mode = clip.wrapMode

-- wrapMode 값에 따라 처리 분기
if mode == VFramework.WrapMode.Loop then
    print("이 클립은 무한 반복 재생됩니다.")
elseif mode == VFramework.WrapMode.Once then
    print("이 클립은 한 번만 재생 후 멈춥니다.")
elseif mode == VFramework.WrapMode.PingPong then
    print("이 클립은 왕복 재생됩니다.")
end
```
