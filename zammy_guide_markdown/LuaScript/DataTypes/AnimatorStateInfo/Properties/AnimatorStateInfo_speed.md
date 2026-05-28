---
title: speed
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_speed
source_path: LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_speed.html
last_updated: "2026.04.06 오후 02:58"
---

# speed

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

speed는 현재 애니메이션 상태가 재생되고 있는 속도 배율을 나타내는 값입니다.

## 프로퍼티 정의

- **이름**: `speed`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

print("현재 애니메이션 Speed:", stateInfo.speed)
```
