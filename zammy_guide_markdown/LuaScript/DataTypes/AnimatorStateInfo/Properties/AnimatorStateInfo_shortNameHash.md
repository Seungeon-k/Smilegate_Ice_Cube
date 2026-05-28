---
title: shortNameHash
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_shortNameHash
source_path: LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_shortNameHash.html
last_updated: "2026.04.06 오후 02:58"
---

# shortNameHash

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

shortNameHash는 현재 재생 중인 애니메이션 상태의 상태 이름(State Name)만을 해시한 값입니다.  

[fullPathHash](AnimatorStateInfo_fullPathHash.md)가 전체 경로(레이어명 + 상태 폴더 경로 + 상태명)를 포함하는 것과 달리,  

shortNameHash는 순수하게 상태 이름만을 기준으로 생성된 해시 값입니다.

## 프로퍼티 정의

- **이름**: `shortNameHash`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

print("현재 상태 이름 해시:", stateInfo.shortNameHash)
```

## 참고 사항

shortNameHash는 상태 이름만 비교하므로, 다른 경로의 동일 이름 상태는 구분하지 못합니다.  

경로까지 구분하려면 [fullPathHash](AnimatorStateInfo_fullPathHash.md)를 사용해야 합니다.
