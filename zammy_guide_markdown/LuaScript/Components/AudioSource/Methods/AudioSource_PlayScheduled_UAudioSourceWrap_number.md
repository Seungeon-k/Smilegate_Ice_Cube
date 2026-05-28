---
title: PlayScheduled
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Methods/AudioSource_PlayScheduled_UAudioSourceWrap_number
source_path: LuaScript/Components/AudioSource/Methods/AudioSource_PlayScheduled_UAudioSourceWrap_number.html
last_updated: "2026.04.06 오후 02:49"
---

# PlayScheduled

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 함수는 특정 시간에 오디오 클립을 재생합니다. 재생 시간은 절대 시간 라인에서 AudioSettings.dspTime이 참조하는 시간으로 설정됩니다. 이 메서드는 오디오 클립을 정확한 시간에 재생해야 할 때 유용합니다.

## 함수

PlayScheduled(time)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `time` | 소리가 재생되어야 하는 절대 시간 라인에서의 초 단위 시간 |

### 반환값

없음

## 예제 코드

```lua
AudioSource:PlayScheduled(time)
```
