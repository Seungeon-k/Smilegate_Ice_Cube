---
title: SyncTransform
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_SyncTransform_UTransformWrap
source_path: LuaScript/Components/Transform/Methods/Transform_SyncTransform_UTransformWrap.html
last_updated: "2026.04.06 오후 02:57"
---

# SyncTransform

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

SyncTransform 메서드는 현재 컨텍스트 상태를 동기화하거나 반영합니다.  

`SyncTransform`는 래퍼에 반영된 위치/회전/스케일 값을 실제 Transform에 즉시 동기화합니다. 물리 계산이 개입되는 객체는 `FixedUpdate` 이후 한 번만 호출해 떨림과 역보간 오차를 줄이세요.  

`SyncTransform`를 여러 스크립트가 동시에 호출하면 결과가 덮어써질 수 있으므로, 호출 주체를 명확히 분리해 관리하세요.

## 함수

SyncTransform()

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| 없음 | - | 입력 인자 없이 현재 [`Transform`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform) 상태를 기준으로 동작을 실행합니다. 호출 전에 대상 객체가 유효한지 확인하고 중복 실행을 방지하세요. |

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    target:SyncTransform()
end
```
