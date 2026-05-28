---
title: isPlaying
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Properties/Animation_isPlaying
source_path: LuaScript/Components/Animation/Properties/Animation_isPlaying.html
last_updated: "2026.04.06 오후 02:48"
---

# isPlaying

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 프로퍼티는 지정된 애니메이션이 현재 재생 중인지 여부를 나타냅니다. 애니메이션이 재생 중일 경우 `true`를 반환하고, 그렇지 않으면 `false`를 반환합니다.

이 프로퍼티는 읽기 전용이며, 애니메이션의 상태를 확인하는 데 유용합니다. 애니메이션이 재생되고 있는지 확인하고자 할 때 사용하면 됩니다.

## 프로퍼티 정의

- **이름**: `isPlaying`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
isPlaying = Animation.isPlaying
```

## 참고 사항

동기화 미지원
