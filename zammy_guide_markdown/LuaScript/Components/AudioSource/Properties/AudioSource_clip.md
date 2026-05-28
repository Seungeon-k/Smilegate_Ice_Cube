---
title: clip
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Properties/AudioSource_clip
source_path: LuaScript/Components/AudioSource/Properties/AudioSource_clip.html
last_updated: "2026.04.06 오후 02:50"
---

# clip

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 프로퍼티는 기본적으로 재생할 AudioClip을 설정하거나 가져오는 데 사용됩니다. AudioSource를 통해 소리를 재생할 때, 이 프로퍼티를 통해 원하는 오디오 클립을 지정할 수 있습니다.

AudioClip을 설정하면, 해당 AudioSource가 재생될 때 지정된 클립이 재생됩니다. 이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 현재 재생 중인 클립을 확인하거나 새로운 클립으로 변경할 수 있습니다.

예외 케이스로는, AudioSource가 활성화되지 않았거나, AudioClip이 null인 경우에는 소리가 재생되지 않을 수 있습니다.

## 프로퍼티 정의

- **이름**: `clip`
- **타입**: `AudioClip`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local clip = audioSource.clip

audioSource.clip = newClip
```

## 참고 사항
