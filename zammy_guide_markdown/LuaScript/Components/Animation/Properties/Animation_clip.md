---
title: clip
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Properties/Animation_clip
source_path: LuaScript/Components/Animation/Properties/Animation_clip.html
last_updated: "2026.04.06 오후 02:48"
---

# clip

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 프로퍼티는 기본 애니메이션을 나타냅니다. 애니메이션 클립을 가져오거나 설정할 수 있습니다.

애니메이션 클립을 설정할 때는 유효한 애니메이션 클립 객체를 제공해야 하며, 그렇지 않을 경우 예외가 발생할 수 있습니다.

이 프로퍼티는 읽기 및 쓰기가 가능하므로, 애니메이션 클립을 동적으로 변경할 수 있습니다.

## 프로퍼티 정의

- **이름**: `clip`
- **타입**: `AnimationClip`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
clip = animation.clip
animation.clip = clip
```

## 참고 사항

동기화 지원
