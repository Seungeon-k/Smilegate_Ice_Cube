---
title: length
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_length
source_path: LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_length.html
last_updated: "2026.04.06 오후 02:58"
---

# length

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

length는 현재 재생 중인 애니메이션 상태의 실제 재생 시간(초 단위) 을 나타내는 값입니다.  

애니메이션 클립 자체의 길이를 의미하며, 속도([speed](AnimatorStateInfo_speed.md))나 [speedMultiplier](AnimatorStateInfo_speedMultiplier.md)에 영향을 받지 않은 원본 기준 길이입니다.

## 프로퍼티 정의

- **이름**: `length`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

print("애니메이션 길이:", stateInfo.length)
```

## 참고 사항

length는 애니메이션 클립의 순수한 길이이며, 속도 또는 배율(speedMultiplier)은 반영되지 않습니다.  
  

루프 애니메이션이라도 length 값은 변하지 않습니다.
