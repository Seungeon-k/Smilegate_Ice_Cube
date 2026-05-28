---
title: humanScale
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_humanScale
source_path: LuaScript/Components/Animator/Properties/Animator_humanScale.html
last_updated: "2026.04.06 오후 02:49"
---

# humanScale

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

현재 아바타의 스케일을 반환합니다. 이 값은 휴머노이드 리그에 대해 설정되며, 일반 리그의 경우 기본값은 1입니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 사용 시 주의해야 할 점은, 아바타가 휴머노이드 리그가 아닐 경우 반환되는 값이 항상 1이라는 점입니다.

## 프로퍼티 정의

- **이름**: `humanScale`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local scale = animator.humanScale
```

## 참고 사항
