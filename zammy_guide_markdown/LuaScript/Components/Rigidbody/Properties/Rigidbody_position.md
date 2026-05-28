---
title: position
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Properties/Rigidbody_position
source_path: LuaScript/Components/Rigidbody/Properties/Rigidbody_position.html
last_updated: "2026.04.06 오후 02:55"
---

# position

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

`position`은(는) 물리에서 현재 좌표 정보를 나타내는 [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 값입니다. 거리 판정, 추적, 보정 계산 로직의 기준으로 활용됩니다. 월드/로컬 좌표계 기준을 혼동하지 않도록 사용 지점을 통일해야 합니다.  

`position` 값은 좌표계(로컬/월드)와 부모 계층 상태에 따라 결과가 달라질 수 있으므로, 연산 직전에 최신 값을 다시 읽어 사용하는 것이 안전합니다.

## 프로퍼티 정의

- **이름**: `position`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.position
    this.scriptObject:Log(tostring(value))
end
```
