---
title: loop
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_loop
source_path: LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_loop.html
last_updated: "2026.04.06 오후 02:58"
---

# loop

## 객체

> [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo)

## 설명

loop는 현재 재생 중인 애니메이션 상태가 루프(반복) 재생되는 애니메이션인지 여부를 나타내는 값입니다.  

true이면 애니메이션이 끝난 뒤 자동으로 다시 처음부터 반복되며,  

false이면 애니메이션이 한 번 재생된 뒤 종료됩니다.

## 프로퍼티 정의

- **이름**: `loop`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local animator = penguin.animator
local stateInfo = animator:GetCurrentAnimatorStateInfo(0)

if stateInfo.loop then
    print("이 애니메이션은 루프 재생됩니다.")
else
    print("이 애니메이션은 1회 재생 후 종료됩니다.")
end

-- 루프가 아닌 애니메이션의 종료 타이밍에 맞춰 처리 예시
if not stateInfo.loop then
    if stateInfo.normalizedTime >= 1.0 then
        print("애니메이션이 종료되었습니다. 다음 동작 실행!")
    end
end
```
