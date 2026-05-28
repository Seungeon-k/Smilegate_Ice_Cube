---
title: center
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_center
source_path: LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_center.html
last_updated: "2026.04.06 오후 02:51"
---

# center

## 객체

> [CapsuleCollider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/CapsuleCollider)

## 설명

이 프로퍼티는 캡슐의 중심을 객체의 로컬 공간에서 측정한 값을 반환합니다. 캡슐의 위치를 조정할 때 유용하게 사용됩니다.

프로퍼티는 읽기와 쓰기가 모두 가능하므로, 캡슐의 중심을 설정하거나 가져올 수 있습니다. 사용 시 주의할 점은, 로컬 공간에서의 위치를 기준으로 하므로, 월드 공간과는 다를 수 있다는 점입니다.

## 프로퍼티 정의

- **이름**: `center`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local center = capsuleCollider.center
capsuleCollider.center = newCenter
```

## 참고 사항

동기화 지원
