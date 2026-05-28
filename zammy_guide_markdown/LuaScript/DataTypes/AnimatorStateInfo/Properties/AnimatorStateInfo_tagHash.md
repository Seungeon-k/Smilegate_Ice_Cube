---
title: tagHash
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_tagHash
source_path: LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_tagHash.html
last_updated: "2026.04.06 오후 02:58"
---

# tagHash

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

tagHash는 현재 재생 중인 애니메이션 상태(State)에 설정된 태그(Tag) 값을 해시한 숫자입니다.  

애니메이션 상태마다 원하는 태그를 지정해두면, 코드에서 이름 비교 없이 빠르고 효율적으로 상태 그룹을 판별할 수 있습니다.

## 프로퍼티 정의

- **이름**: `tagHash`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

print("현재 태그 해시:", stateInfo.tagHash)
```
