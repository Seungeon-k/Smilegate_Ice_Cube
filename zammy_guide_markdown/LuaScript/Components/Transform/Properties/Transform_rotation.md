---
title: rotation
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_rotation
source_path: LuaScript/Components/Transform/Properties/Transform_rotation.html
last_updated: "2026.04.06 오후 02:58"
---

# rotation

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 월드 공간에서 Transform의 회전을 저장하는 [Quaternion](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)을 반환합니다. 회전 값은 3D 공간에서 객체의 방향을 정의하며, 이를 통해 객체의 회전을 조정할 수 있습니다.

회전 값을 설정할 때는 [Quaternion](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion) 형식의 값을 사용해야 하며, 잘못된 형식의 값을 설정할 경우 예외가 발생할 수 있습니다. 이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 현재 회전 값을 가져오거나 새로운 회전 값을 설정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `rotation`
- **타입**: [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local rotation = transform.rotation
transform.rotation = newRotation
```

## 참고 사항

동기화 지원
