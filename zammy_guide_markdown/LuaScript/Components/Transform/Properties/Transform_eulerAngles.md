---
title: eulerAngles
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_eulerAngles
source_path: LuaScript/Components/Transform/Properties/Transform_eulerAngles.html
last_updated: "2026.04.06 오후 02:57"
---

# eulerAngles

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 회전을 오일러 각도로 표현하며, 단위는 도(degree)입니다. 이 값을 사용하여 객체의 회전을 설정하거나 가져올 수 있습니다.

회전 값은 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형태로 반환되며, 각 축에 대한 회전 각도를 포함합니다. 이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 필요에 따라 회전 값을 수정할 수 있습니다.

회전 각도는 0도에서 360도 사이의 값을 가질 수 있으며, 특정 상황에서는 예상치 못한 결과를 초래할 수 있습니다. 예를 들어, 회전 값이 360도를 초과하거나 -360도 미만일 경우, 내부적으로 값이 정상화되어 처리됩니다.

## 프로퍼티 정의

- **이름**: `eulerAngles`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local rotation = transform.eulerAngles
transform.eulerAngles = Vector3(30, 45, 60)
```

## 참고 사항

동기화 지원
