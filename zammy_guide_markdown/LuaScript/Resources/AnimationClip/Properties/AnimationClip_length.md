---
title: length
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_length
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_length.html
last_updated: "2026.04.06 오후 03:21"
---

# length

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

length는 해당 AnimationClip의 전체 재생 시간(초 단위) 을 나타내는 읽기 전용 속성입니다.  

이 값은 클립에 포함된 키프레임의 시작 시점부터 마지막 키프레임 시점까지의 총 길이를 의미합니다.  

예를 들어 length가 2.0이라면, 해당 애니메이션은 기본 재생 속도(1.0)일 때 2초 동안 재생됩니다.

이 속성은 애니메이션 이벤트 타이밍, 루프 설정, 재생 속도 계산 등 다양한 상황에서 중요한 기준이 됩니다

## 프로퍼티 정의

- **이름**: `length`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimatonClip

print("애니메이션 길이(초): " .. clip.length)

-- 재생 속도를 변경하여 실제 재생 시간 계산하기
local playbackSpeed = 1.5
local actualDuration = clip.length / playbackSpeed
print("재생 속도 1.5배 적용 시 실제 재생 시간(초): " .. actualDuration)

-- 특정 프레임 위치로 계산
local fps = clip.frameRate
local totalFrames = clip.length * fps
print("총 프레임 수: " .. totalFrames)
```
