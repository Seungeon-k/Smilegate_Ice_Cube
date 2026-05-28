---
title: Stop
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Methods/AudioSource_Stop_UAudioSourceWrap
source_path: LuaScript/Components/AudioSource/Methods/AudioSource_Stop_UAudioSourceWrap.html
last_updated: "2026.04.06 오후 02:50"
---

# Stop

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 함수는 현재 재생 중인 오디오 클립을 중지합니다. 호출 후에는 오디오 클립이 더 이상 재생되지 않으며, 다음에 재생할 때는 다시 `Play` 메서드를 호출해야 합니다. 이 함수는 인수가 필요하지 않으며, 호출 시 특별한 예외 케이스는 없습니다.

## 함수

Stop()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
AudioSource:Stop()
```
