---
title: mute
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Properties/AudioSource_mute
source_path: LuaScript/Components/AudioSource/Properties/AudioSource_mute.html
last_updated: "2026.04.06 오후 02:50"
---

# mute

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 프로퍼티는 오디오 소스를 음소거하거나 음소거 해제하는 기능을 제공합니다. 음소거를 설정하면 볼륨이 0으로 설정되며, 음소거 해제를 통해 원래의 볼륨으로 복원됩니다.

이 프로퍼티를 사용할 때는 음소거 상태에 따라 오디오의 출력이 달라지므로, 적절한 시점에 음소거 및 음소거 해제를 수행해야 합니다. 예를 들어, 게임의 특정 이벤트에 따라 오디오를 조절할 수 있습니다.

## 프로퍼티 정의

- **이름**: `mute`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local isMuted = audioSource.mute

audioSource.mute = true  -- 음소거 설정

audioSource.mute = false -- 음소거 해제
```

## 참고 사항
