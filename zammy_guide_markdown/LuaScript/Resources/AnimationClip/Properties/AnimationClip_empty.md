---
title: empty
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_empty
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_empty.html
last_updated: "2026.04.06 오후 03:20"
---

# empty

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

empty는 해당 AnimationClip이 모션 데이터를 포함하고 있는지 여부를 반환하는 읽기 전용 속성입니다.  

만약 클립에 키프레임 곡선, 루트 모션, 파라미터 곡선 등 어떠한 애니메이션 데이터도 존재하지 않는다면 true를 반환하고, 데이터가 하나라도 존재하면 false를 반환합니다.

이 속성은 런타임에서 애니메이션 클립의 유효성을 검사하거나 빈 애니메이션이 로드된 경우 처리 로직을 분기하는 데 자주 사용됩니다.

## 프로퍼티 정의

- **이름**: `empty`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

-- 클립이 비어 있는지 확인
if clip.empty then
    print("이 애니메이션 클립은 비어 있습니다.")
else
    print("이 애니메이션 클립에는 모션 데이터가 존재합니다.")
end
```
