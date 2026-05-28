---
title: position
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_position
source_path: LuaScript/Components/Transform/Properties/Transform_position.html
last_updated: "2026.04.06 오후 02:58"
---

# position

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 Transform의 월드 공간 위치를 나타냅니다. 이 값을 통해 객체의 위치를 설정하거나 가져올 수 있습니다.

위치 값은 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형식으로 반환되며, x, y, z 좌표를 포함합니다. 이 프로퍼티를 사용하여 객체의 위치를 조정할 수 있으며, 위치를 변경하면 해당 객체가 씬 내에서 이동하게 됩니다.

이 프로퍼티는 읽기 및 쓰기가 가능하므로, 현재 위치를 가져오거나 새로운 위치로 설정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `position`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local position = transform.position
transform.position = newPosition
```

## 참고 사항

동기화 지원
