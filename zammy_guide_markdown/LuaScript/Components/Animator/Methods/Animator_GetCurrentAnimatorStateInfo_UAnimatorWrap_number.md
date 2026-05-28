---
title: GetCurrentAnimatorStateInfo
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_GetCurrentAnimatorStateInfo_UAnimatorWrap_number
source_path: LuaScript/Components/Animator/Methods/Animator_GetCurrentAnimatorStateInfo_UAnimatorWrap_number.html
last_updated: "2026.04.06 오후 02:48"
---

# GetCurrentAnimatorStateInfo

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

GetCurrentAnimatorStateInfo 메서드는 layerIndex 기준으로 데이터를 조회합니다.  

`GetCurrentAnimatorStateInfo`는 호출 시점의 상태를 반환하므로 상태 갱신 직전/직후 위치를 명확히 분리해 읽어야 의도한 값이 보장됩니다.  

`GetCurrentAnimatorStateInfo`를 여러 스크립트가 동시에 호출하면 결과가 덮어써질 수 있으므로, 호출 주체를 명확히 분리해 관리하세요.

## 함수

GetCurrentAnimatorStateInfo(layerIndex)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| number | layerIndex | `layerIndex`는 목록/페이지 위치를 지정하는 인덱스 값입니다. 0 기반 여부와 최대 범위를 확인해 요청 범위를 넘지 않도록 사용하세요. |

### 반환값

`GetCurrentAnimatorStateInfo` 호출 시점의 [AnimatorStateInfo](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/AnimatorStateInfo) 데이터를 반환합니다. 반환값이 nil/빈 값일 수 있으므로 검증 후 후속 로직으로 전달하세요.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    target:GetCurrentAnimatorStateInfo(0)
end
```
