---
title: volume
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Properties/AudioSource_volume
source_path: LuaScript/Components/AudioSource/Properties/AudioSource_volume.html
last_updated: "2026.04.06 오후 02:50"
---

# volume

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 프로퍼티는 오디오 소스의 볼륨을 설정하거나 가져오는 데 사용됩니다. 볼륨 값은 0.0에서 1.0 사이의 실수로 표현되며, 0.0은 음소거를 의미하고 1.0은 최대 볼륨을 의미합니다.

볼륨을 설정할 때는 유효한 범위 내의 값을 사용해야 하며, 범위를 벗어난 값은 적용되지 않을 수 있습니다. 이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 현재 볼륨을 확인하거나 새로운 값을 설정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `volume`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local currentVolume = AudioSource.volume
AudioSource.volume = 0.5
```

## 참고 사항
