---
title: speedMultiplier
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_speedMultiplier
source_path: LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_speedMultiplier.html
last_updated: "2026.04.06 오후 02:58"
---

# speedMultiplier

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

speedMultiplier는 현재 애니메이션 상태의 최종 재생 속도에 영향을 주는 배율 값입니다.  

[speed](AnimatorStateInfo_speed.md)가 상태(State) 자체의 속도를 의미한다면,  

speedMultiplier는 [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator) 의해 적용되는 추가 속도 배율입니다.

## 프로퍼티 정의

- **이름**: `speedMultiplier`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

-- speedMultiplier 값 확인
print("speedMultiplier:", stateInfo.speedMultiplier)

-- 최종 애니메이션 속도 계산
local finalSpeed = stateInfo.speed * stateInfo.speedMultiplier
print("최종 애니메이션 재생 속도:", finalSpeed)

-- 애니메이션이 지나치게 빠르면 경고 출력
if finalSpeed > 2.0 then
    print("애니메이션이 과도하게 빠르게 재생되고 있습니다.")
end
```
