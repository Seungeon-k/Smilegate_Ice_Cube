---
title: loop
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource/Properties/AudioSource_loop
source_path: LuaScript/Components/AudioSource/Properties/AudioSource_loop.html
last_updated: "2026.04.06 오후 02:50"
---

# loop

## 객체

> [AudioSource](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/AudioSource)

## 설명

이 프로퍼티는 오디오 클립이 반복 재생되는지를 나타냅니다. `true`로 설정하면 오디오 클립이 끝나고 다시 처음부터 재생됩니다. 기본값은 `false`입니다.

이 프로퍼티를 사용하여 오디오 클립의 반복 여부를 제어할 수 있으며, 오디오 클립이 반복 재생되도록 설정할 경우, 클립이 끝나면 자동으로 처음부터 다시 시작합니다.

예외적으로, 오디오 클립이 재생 중일 때 이 값을 변경하면 즉시 적용되지 않을 수 있습니다. 이 경우, 클립이 다음에 시작될 때 설정된 값이 적용됩니다.

## 프로퍼티 정의

- **이름**: `loop`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
audioSource.loop = true
```

## 참고 사항
