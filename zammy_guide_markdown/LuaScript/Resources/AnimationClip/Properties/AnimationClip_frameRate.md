---
title: frameRate
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_frameRate
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_frameRate.html
last_updated: "2026.04.06 오후 03:20"
---

# frameRate

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

frameRate는 AnimationClip의 초당 프레임 수(FPS, Frames Per Second) 를 나타내는 속성입니다.  

이 값은 애니메이션 데이터가 시간이 아닌 프레임 단위로 어떻게 구성되어 있는지를 결정하며, 애니메이션의 정밀도와 재생 해상도에 영향을 줍니다.

예를 들어 frameRate가 30이면 초당 30프레임으로, 1초에 30개의 키프레임 또는 보간 프레임이 처리됩니다.

## 프로퍼티 정의

- **이름**: `frameRate`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

-- 프레임 레이트 출력
print("애니메이션 FPS: " .. clip.frameRate)

-- FPS를 기준으로 전체 프레임 수 계산하기
local totalFrames = clip.frameRate * clip.length
print("총 프레임 수: " .. totalFrames)
```
