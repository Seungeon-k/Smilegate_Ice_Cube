---
title: fullPathHash
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_fullPathHash
source_path: LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_fullPathHash.html
last_updated: "2026.04.06 오후 02:58"
---

# fullPathHash

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

fullPathHash는 현재 애니메이션 상태의 전체 경로 이름(Full Path Name) 을 해시한 값입니다.  

이는 애니메이터의 레이어 이름 + 상태 머신 경로 + 상태 이름을 모두 포함한 고유한 해시 값으로,  

여러 상태 이름이 동일하더라도 레이어나 경로가 다를 경우 완전히 다른 해시 값이 생성됩니다.

## 프로퍼티 정의

- **이름**: `fullPathHash`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
-- 레이어 0의 현재 애니메이션 상태 fullPathHash 확인

local stateInfo = penguin.animator:GetCurrentAnimatorStateInfo(0)

print("현재 상태 해시:", stateInfo.fullPathHash)
```

## 참고 사항

fullPathHash는 상태 전체 경로 기준이므로 단순 이름(shortNameHash)보다 충돌 위험이 훨씬 적습니다.
