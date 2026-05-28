---
title: center
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/SphereCollider/Properties/SphereCollider_center
source_path: LuaScript/Components/SphereCollider/Properties/SphereCollider_center.html
last_updated: "2026.04.06 오후 02:55"
---

# center

## 객체

> [SphereCollider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/SphereCollider)

## 설명

이 프로퍼티는 객체의 로컬 공간에서 구의 중심을 나타냅니다. 구의 중심을 설정하거나 가져오는 데 사용됩니다. 이 프로퍼티는 읽기 및 쓰기가 가능하며, 구의 위치를 조정할 때 유용합니다. 사용 시 주의할 점은, 구의 중심을 변경하면 물리적 상호작용에 영향을 줄 수 있으므로, 적절한 시점에 값을 설정해야 합니다.

## 프로퍼티 정의

- **이름**: `center`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local center = sphereCollider.center
sphereCollider.center = newCenter
```

## 참고 사항

동기화 지원
