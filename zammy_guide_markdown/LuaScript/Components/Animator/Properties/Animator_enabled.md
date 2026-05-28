---
title: enabled
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_enabled
source_path: LuaScript/Components/Animator/Properties/Animator_enabled.html
last_updated: "2026.04.06 오후 02:49"
---

# enabled

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

`enabled`은(는) 해당 기능의 활성/차단 여부를 나타내는 `boolean` 상태 값입니다. 입력 분기와 예외 처리 판단 기준으로 사용됩니다. 상태 전환 직후 연관 시스템 반영 시점을 함께 확인하는 구성이 안정적입니다.  

`enabled` 값은 객체의 활성/비활성 전환과 이벤트 처리 순서에 따라 프레임 단위로 바뀔 수 있으니, 분기 직전에 확인해 사용하는 것이 좋습니다.  

멀티플레이에서는 `enabled`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: enabled
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
function this.OnStart()
    local animator = this.scriptObject:GetComponent("Animator")
    if animator == nil then
        return
    end

    animator.enabled = false
    this.scriptObject:Log("Animator를 비활성화했습니다.")
end
```
