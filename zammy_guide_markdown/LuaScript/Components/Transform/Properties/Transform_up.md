---
title: up
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_up
source_path: LuaScript/Components/Transform/Properties/Transform_up.html
last_updated: "2026.04.06 오후 02:58"
---

# up

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 월드 공간에서 변환의 녹색 축을 나타냅니다. 이 축은 주로 객체의 위쪽 방향을 정의하는 데 사용됩니다. 사용자는 이 프로퍼티를 통해 객체의 방향을 조정할 수 있습니다.

이 프로퍼티는 읽기 및 쓰기가 가능하므로, 현재 방향을 가져오거나 새로운 방향으로 설정할 수 있습니다. 그러나 잘못된 방향 벡터를 설정할 경우 예기치 않은 동작이 발생할 수 있으므로 주의해야 합니다.

## 프로퍼티 정의

- **이름**: `up`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local upVector = transform.up
transform.up = newVector
```

## 참고 사항

동기화 지원
