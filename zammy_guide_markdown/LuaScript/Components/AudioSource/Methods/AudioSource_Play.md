---
title: Play
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Methods/AudioSource_Play
source_path: LuaScript/Components/AudioSource/Methods/AudioSource_Play.html
last_updated: "2026.04.06 오후 02:49"
---

# Play

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 함수는 현재 설정된 오디오 클립을 재생합니다. 호출 시 클립이 재생되며, 이전에 재생 중인 클립이 있다면 중단됩니다. 이 함수는 오디오 소스가 활성화되어 있어야 정상적으로 작동합니다. 만약 오디오 소스가 비활성화되어 있다면, 재생되지 않습니다.

이 함수는 오디오 클립을 재생합니다. `delay` 매개변수는 더 이상 사용되지 않으며, 44100Hz 샘플 레이트를 기준으로 샘플 수로 지연을 설정하는 데 사용되었습니다. 예를 들어, `Play(44100)`은 재생을 정확히 1초 지연시킵니다. 이 매개변수는 현재는 무시되므로, 호출 시 인자를 제공할 필요가 없습니다.

## 함수

Play()  
  

Play(delay)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `delay` | 더 이상 사용되지 않음. 44100Hz 샘플 레이트를 기준으로 한 샘플 수로 지연을 설정 |

### 반환값

없음

## 예제 코드

```lua
AudioSource:Play(delay)
```
