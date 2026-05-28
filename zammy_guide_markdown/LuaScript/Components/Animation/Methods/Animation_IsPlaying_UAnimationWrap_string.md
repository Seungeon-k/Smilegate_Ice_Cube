---
title: IsPlaying
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Methods/Animation_IsPlaying_UAnimationWrap_string
source_path: LuaScript/Components/Animation/Methods/Animation_IsPlaying_UAnimationWrap_string.html
last_updated: "2026.04.06 오후 02:47"
---

# IsPlaying

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

애니메이션이 현재 재생 중인지 여부를 나타냅니다. 애니메이션이 재생 중일 경우 `true`를 반환하고, 그렇지 않으면 `false`를 반환합니다.

## 함수

IsPlaying(name)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `string` | `name` | 애니메이션 이름 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 애니메이션이 재생 중일 경우 `true`를 반환하고, 그렇지 않으면 `false`를 반환 |

## 예제 코드

```lua
Animation.IsPlaying(animation)
```
