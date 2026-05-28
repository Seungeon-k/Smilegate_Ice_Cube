---
title: size
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/BoxCollider/Properties/BoxCollider_size
source_path: LuaScript/Components/BoxCollider/Properties/BoxCollider_size.html
last_updated: "2026.04.06 오후 02:50"
---

# size

## 객체

> [BoxCollider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/BoxCollider)

## 설명

이 프로퍼티는 박스의 크기를 객체의 로컬 공간에서 측정한 값을 반환합니다. 크기는 [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형태로 표현되며, 각 축에 대한 크기를 나타냅니다. 이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 객체의 크기를 동적으로 변경할 수 있습니다.

크기를 설정할 때는 주의가 필요합니다. 잘못된 값이 설정될 경우, 물리적 충돌이나 시각적 표현에 문제가 발생할 수 있습니다. 또한, 이 프로퍼티는 동기화가 지원되므로, 여러 스레드에서 동시에 접근할 경우 일관성을 유지할 수 있습니다.

## 프로퍼티 정의

- **이름**: `size`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local size = boxCollider.size
boxCollider.size = newSize
```

## 참고 사항
