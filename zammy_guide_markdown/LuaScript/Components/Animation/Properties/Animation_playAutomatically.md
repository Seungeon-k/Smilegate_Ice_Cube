---
title: playAutomatically
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Properties/Animation_playAutomatically
source_path: LuaScript/Components/Animation/Properties/Animation_playAutomatically.html
last_updated: "2026.04.06 오후 02:48"
---

# playAutomatically

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 프로퍼티는 기본 애니메이션 클립(애니메이션.clip 속성)이 시작 시 자동으로 재생될지를 결정합니다.

기본값이 true로 설정되어 있으면, 애니메이션이 시작할 때 자동으로 재생됩니다. 이 값을 false로 설정하면, 애니메이션이 자동으로 재생되지 않으며, 수동으로 재생해야 합니다.

이 프로퍼티는 읽기 및 쓰기가 가능하므로, 필요에 따라 애니메이션의 자동 재생 여부를 동적으로 변경할 수 있습니다.

## 프로퍼티 정의

- **이름**: `playAutomatically`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
value = Animation.playAutomatically
Animation.playAutomatically = value
```

## 참고 사항

동기화 지원
