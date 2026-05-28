---
title: normalizedTime
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_normalizedTime
source_path: LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_normalizedTime.html
last_updated: "2026.04.06 오후 02:58"
---

# normalizedTime

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

normalizedTime은 현재 재생 중인 애니메이션이 얼마나 진행되었는지를 0~1 구간으로 표현한 값입니다.

- 
  0.0 → 애니메이션 시작
- 
  1.0 → 애니메이션 1회 재생 완료
- 
  1.5 → 루프 애니메이션이 1.5회 재생됨
- 
  2.0 → 2회 재생됨

즉, 루프 애니메이션에서는 1을 넘어서 계속 증가하며,  

비루프 애니메이션에서는 1.0을 넘기면 그대로 Completion 판단에 활용할 수 있습니다.

## 프로퍼티 정의

- **이름**: `normalizedTime`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

print("normalizedTime:", stateInfo.normalizedTime)

-- 애니메이션이 거의 끝났는지 체크
if stateInfo.normalizedTime >= 0.9 then
    print("애니메이션이 90% 이상 진행됨")
end

-- 루프 애니메이션 재생 횟수 출력
if stateInfo.loop then
    local loopCount = math.floor(stateInfo.normalizedTime)
    print("루프 재생 횟수:", loopCount)
end
```
