---
title: Pause
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Methods/AudioSource_Pause_UAudioSourceWrap
source_path: LuaScript/Components/AudioSource/Methods/AudioSource_Pause_UAudioSourceWrap.html
last_updated: "2026.04.06 오후 02:49"
---

# Pause

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 함수는 현재 재생 중인 오디오 클립을 일시 정지합니다. 일시 정지된 상태에서 다시 재생하려면 `AudioSource.UnPause` 함수를 호출해야 합니다. 이 함수는 인수가 필요하지 않으며, 호출 시 현재 재생 상태에 따라 동작합니다. 만약 이미 일시 정지 상태라면, 호출해도 아무런 효과가 없습니다.

## 함수

Pause()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
AudioSource:Pause()
```
