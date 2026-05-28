---
title: pitch
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Properties/AudioSource_pitch
source_path: LuaScript/Components/AudioSource/Properties/AudioSource_pitch.html
last_updated: "2026.04.06 오후 02:50"
---

# pitch

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 프로퍼티는 오디오 소스의 피치를 설정하거나 가져오는 데 사용됩니다. 피치는 오디오의 높낮이를 조절하며, 값이 1.0일 때 기본 피치를 의미합니다. 피치 값은 0.0 이상이어야 하며, 1.0보다 큰 값은 소리를 높이고, 1.0보다 작은 값은 소리를 낮춥니다.

피치를 설정할 때는 유의사항으로, 너무 높은 피치는 왜곡을 초래할 수 있으며, 너무 낮은 피치는 소리가 들리지 않을 수 있습니다. 또한, 피치를 변경할 때는 오디오 소스가 재생 중인지 확인하는 것이 좋습니다. 재생 중인 오디오 소스의 피치를 변경하면 즉시 반영됩니다.

## 프로퍼티 정의

- **이름**: `pitch`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local pitch = audioSource.pitch

audioSource.pitch = newPitch
```

## 참고 사항
