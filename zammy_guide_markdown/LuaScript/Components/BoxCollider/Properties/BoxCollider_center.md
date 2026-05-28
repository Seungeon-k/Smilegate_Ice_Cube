---
title: center
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/BoxCollider/Properties/BoxCollider_center
source_path: LuaScript/Components/BoxCollider/Properties/BoxCollider_center.html
last_updated: "2026.04.06 오후 02:50"
---

# center

## 객체

> [BoxCollider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/BoxCollider)

## 설명

이 프로퍼티는 박스의 중심을 객체의 로컬 공간에서 측정한 값을 반환합니다. 이 값을 통해 박스의 위치를 조정할 수 있으며, 물리적 상호작용에 영향을 미칩니다.

값을 설정할 때는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형식의 값을 사용해야 하며, 잘못된 형식의 값을 설정할 경우 예외가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `center`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local center = boxCollider.center
boxCollider.center = newCenter
```

## 참고 사항
