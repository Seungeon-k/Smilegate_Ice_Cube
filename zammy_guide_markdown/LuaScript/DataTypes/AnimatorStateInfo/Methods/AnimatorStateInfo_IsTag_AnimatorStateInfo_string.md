---
title: IsTag
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Methods/AnimatorStateInfo_IsTag_AnimatorStateInfo_string
source_path: LuaScript/DataTypes/AnimatorStateInfo/Methods/AnimatorStateInfo_IsTag_AnimatorStateInfo_string.html
last_updated: "2026.04.06 오후 02:58"
---

# IsTag

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

IsTag는 현재 애니메이션 상태가 지정된 태그(Tag) 를 가지고 있는지 확인하는 함수입니다.  

Animator 내부에서 각 State는 하나의 태그를 가질 수 있으며, 이 태그를 통해 여러 애니메이션 상태를 하나의 묶음처럼 그룹화하여 처리할 수 있습니다.

## 함수

IsTag(tagName)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | tagName | 확인할 태그 이름. Animator State에 설정된 Tag와 동일해야 합니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| boolean | 현재 상태가 tagName과 동일한 태그를 가지고 있으면 true, 그렇지 않으면 false |

## 예제 코드

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

-- Jump 태그 검출
if stateInfo:IsTag("Jump") then
    print("Jump 태그 상태입니다.")
end
```
