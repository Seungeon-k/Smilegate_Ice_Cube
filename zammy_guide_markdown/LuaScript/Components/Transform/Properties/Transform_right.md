---
title: right
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_right
source_path: LuaScript/Components/Transform/Properties/Transform_right.html
last_updated: "2026.04.06 오후 02:58"
---

# right

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 월드 공간에서 변환의 빨간 축을 나타냅니다. 이 축은 주로 오른쪽 방향을 가리키며, 3D 공간에서 객체의 방향을 조정하는 데 사용됩니다.

이 프로퍼티는 읽기 및 쓰기가 가능하므로, 현재의 오른쪽 방향을 가져오거나 새로운 방향으로 설정할 수 있습니다. 설정할 때는 반드시 유효한 벡터 값을 사용해야 하며, 잘못된 값이 입력될 경우 예외가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `right`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local rightVector = transform.right
transform.right = newVector
```

## 참고 사항

동기화 지원
