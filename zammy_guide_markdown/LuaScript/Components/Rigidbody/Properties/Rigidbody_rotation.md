---
title: rotation
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody/Properties/Rigidbody_rotation
source_path: LuaScript/Components/Rigidbody/Properties/Rigidbody_rotation.html
last_updated: "2026.04.06 오후 02:55"
---

# rotation

## 객체

> [Rigidbody](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)

## 설명

`rotation`은(는) 물리 회전 상태를 나타내는 [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion) 값입니다. 방향 정렬, 회전 보간, 카메라/모델 동기화 처리에 활용됩니다. 회전 누적 오차를 줄이기 위해 타입 연산 기반으로 구성하는 것이 좋습니다.  

`rotation` 값은 좌표계(로컬/월드)와 부모 계층 상태에 따라 결과가 달라질 수 있으므로, 연산 직전에 최신 값을 다시 읽어 사용하는 것이 안전합니다.

## 프로퍼티 정의

- **이름**: `rotation`
- **타입**: [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.rotation
    this.scriptObject:Log(tostring(value))
end
```
