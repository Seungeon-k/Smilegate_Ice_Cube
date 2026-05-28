---
title: updateMode
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_updateMode
source_path: LuaScript/Components/Animator/Properties/Animator_updateMode.html
last_updated: "2026.04.06 오후 02:49"
---

# updateMode

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 애니메이터의 업데이트 모드를 지정합니다. 애니메이터의 업데이트 모드는 애니메이션이 어떻게 업데이트되는지를 결정하며, 다음과 같은 세 가지 모드가 있습니다:

- **Normal**: 애니메이터의 일반적인 업데이트 방식입니다.
- **AnimatePhysics**: 물리 루프 중에 애니메이터를 업데이트하여 애니메이션 시스템과 물리 엔진이 동기화되도록 합니다.
- **UnscaledTime**: 애니메이터가 `Time.timeScale`과 무관하게 업데이트됩니다.

이 프로퍼티는 애니메이터의 동작 방식에 중요한 영향을 미치므로, 적절한 모드를 선택하는 것이 중요합니다.

## 프로퍼티 정의

- **이름**: `updateMode`
- **타입**: [AnimatorUpdateMode](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/AnimatorUpdateMode)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local updateMode = animator.updateMode
if updateMode == AnimatorUpdateMode.AnimatePhysics then
    this.scriptObject:Log("Animator가 물리 루프 기준으로 업데이트됩니다.")
end
```

## 참고 사항
