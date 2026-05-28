---
title: mass
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Properties/Rigidbody_mass
source_path: LuaScript/Components/Rigidbody/Properties/Rigidbody_mass.html
last_updated: "2026.04.06 오후 02:55"
---

# mass

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

`mass`은(는) 물리 연산에서 관성 반응을 결정하는 `number` 값입니다. 같은 힘을 적용해도 질량에 따라 이동 체감이 달라집니다. 값 조정 시에는 충돌 반응과 속도 제한 규칙을 함께 테스트해야 합니다.  

`mass` 값은 `Rigidbody`의 현재 상태를 직접 반영하므로 초기화/활성화 시점 차이를 고려해 사용 직전에 조회하는 방식이 안전합니다.

## 프로퍼티 정의

- **이름**: `mass`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.mass
    this.scriptObject:Log(tostring(value))
end
```
