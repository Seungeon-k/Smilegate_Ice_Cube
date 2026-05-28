---
title: IsName
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Methods/AnimatorStateInfo_IsName_AnimatorStateInfo_string
source_path: LuaScript/DataTypes/AnimatorStateInfo/Methods/AnimatorStateInfo_IsName_AnimatorStateInfo_string.html
last_updated: "2026.04.06 오후 02:58"
---

# IsName

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

IsName은 현재 애니메이션 상태의 이름(State Name) 이 지정한 문자열과 일치하는지 확인하는 함수입니다.

## 함수

IsName(name)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | name | 비교할 상태 이름 또는 전체 경로 이름. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 현재 상태의 이름이 입력한 name과 일치하면 true, 아니면 false |

## 예제 코드

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

-- 상태 이름 직접 비교
if stateInfo:IsName("Idle") then
    print("현재 상태는 Idle 입니다.")
end
```
