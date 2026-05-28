---
title: PlayDelayed
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Methods/AudioSource_PlayDelayed_UAudioSourceWrap_number
source_path: LuaScript/Components/AudioSource/Methods/AudioSource_PlayDelayed_UAudioSourceWrap_number.html
last_updated: "2026.04.06 오후 02:49"
---

# PlayDelayed

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 함수는 지정된 초만큼의 지연 후에 오디오 클립을 재생합니다. 사용자는 이전의 Play(delay) 함수를 대신하여 이 함수를 사용하는 것이 좋습니다. 이전 함수는 44.1 kHz의 기준 비율에 대한 샘플로 지연 시간을 지정했습니다. 이 함수는 더 직관적이며, 초 단위로 지연 시간을 설정할 수 있습니다.

## 함수

PlayDelayed(delay)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `delay` | 초 단위로 지정된 지연 시간 |

### 반환값

없음

## 예제 코드

```lua
AudioSource:PlayDelayed(delay)
```
