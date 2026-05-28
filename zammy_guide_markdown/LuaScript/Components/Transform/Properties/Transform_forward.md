---
title: forward
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_forward
source_path: LuaScript/Components/Transform/Properties/Transform_forward.html
last_updated: "2026.04.06 오후 02:57"
---

# forward

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 월드 공간에서 변환의 파란 축을 나타내는 정규화된 벡터를 반환합니다. 이 벡터는 변환의 방향을 나타내며, 주로 물체의 전방 방향을 정의하는 데 사용됩니다.

이 프로퍼티는 읽기 및 쓰기가 가능하므로, 변환의 전방 방향을 설정할 수도 있습니다. 그러나 설정할 때는 벡터의 크기를 1로 정규화해야 합니다. 그렇지 않으면 예기치 않은 동작이 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `forward`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local forwardVector = transform.forward
transform.forward = newVector
```

## 참고 사항

동기화 지원
