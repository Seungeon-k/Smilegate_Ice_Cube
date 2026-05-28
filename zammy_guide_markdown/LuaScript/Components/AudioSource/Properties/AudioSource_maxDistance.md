---
title: maxDistance
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Properties/AudioSource_maxDistance
source_path: LuaScript/Components/AudioSource/Properties/AudioSource_maxDistance.html
last_updated: "2026.04.06 오후 02:50"
---

# maxDistance

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 프로퍼티는 소리가 들리지 않거나 감쇠가 멈추는 거리입니다. 이는 롤오프 모드에 따라 달라집니다. 사용자는 이 값을 설정하여 소리의 감쇠 범위를 조정할 수 있습니다.

이 프로퍼티는 읽기 및 쓰기가 가능하며, 소리의 최대 거리 설정에 유용합니다. 주의할 점은 이 값을 너무 크게 설정하면 소리가 너무 멀리 퍼져서 원치 않는 효과를 초래할 수 있습니다.

## 프로퍼티 정의

- **이름**: `maxDistance`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local maxDistance = audioSource.maxDistance

audioSource.maxDistance = 100
```

## 참고 사항
