---
title: PlayOneShot
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Methods/AudioSource_PlayOneShot
source_path: LuaScript/Components/AudioSource/Methods/AudioSource_PlayOneShot.html
last_updated: "2026.04.06 오후 02:49"
---

# PlayOneShot

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 함수는 지정된 AudioClip을 재생합니다. AudioSource의 볼륨은 volumeScale에 따라 조정됩니다. 이 메서드는 AudioClip을 한 번만 재생하며, 반복 재생이 필요할 경우 다른 방법을 사용해야 합니다.

이 함수는 지정된 AudioClip을 재생하며, AudioSource의 볼륨을 volumeScale에 따라 조정합니다. volumeScale이 0보다 작으면 자동으로 0으로 클램프됩니다. 1보다 큰 스케일은 클리핑을 유발할 수 있으므로 주의해야 합니다.

## 함수

PlayOneShot(clip)  
  

PlayOneShot(clip, volumeScale)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`AudioClip`](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AudioClip) | `clip` | 재생할 클립 재생할 오디오 클립 |
| `number` | `volumeScale` | 볼륨의 스케일 |

### 반환값

없음

## 예제 코드

```lua
AudioSource:PlayOneShot(clip, volumeScale)
```
