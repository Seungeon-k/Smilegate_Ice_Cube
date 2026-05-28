---
title: minDistance
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Properties/AudioSource_minDistance
source_path: LuaScript/Components/AudioSource/Properties/AudioSource_minDistance.html
last_updated: "2026.04.06 오후 02:50"
---

# minDistance

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 프로퍼티는 오디오 소스의 최소 거리(minDistance)를 설정하거나 가져오는 데 사용됩니다. 최소 거리 내에서는 오디오 소스의 볼륨이 더 이상 증가하지 않습니다. 이 값을 조정하여 오디오의 공간적 효과를 제어할 수 있습니다.

유의사항으로는, 이 값이 너무 작으면 소리가 너무 가까운 거리에서만 들릴 수 있으며, 너무 크면 소리가 멀리서도 들릴 수 있습니다. 적절한 값을 설정하여 원하는 오디오 효과를 얻는 것이 중요합니다.

## 프로퍼티 정의

- **이름**: `minDistance`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local minDistance = audioSource.minDistance

audioSource.minDistance = 10.0
```

## 참고 사항
