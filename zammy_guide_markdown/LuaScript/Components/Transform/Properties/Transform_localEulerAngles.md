---
title: localEulerAngles
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_localEulerAngles
source_path: LuaScript/Components/Transform/Properties/Transform_localEulerAngles.html
last_updated: "2026.04.06 오후 02:57"
---

# localEulerAngles

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 부모 변환의 회전과 관련된 각도를 도 단위로 표현한 오일러 각을 반환하거나 설정합니다. 이 값을 사용하여 객체의 회전을 조정할 수 있습니다.

회전 값은 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형식으로 제공되며, x, y, z 축에 대한 회전 각도를 포함합니다. 이 프로퍼티를 사용할 때는 부모 변환의 회전 상태에 따라 결과가 달라질 수 있음을 유의해야 합니다.

## 프로퍼티 정의

- **이름**: `localEulerAngles`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local eulerAngles = transform.localEulerAngles
transform.localEulerAngles = Vector3(30, 45, 60)
```

## 참고 사항

동기화 지원
