---
title: height
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_height
source_path: LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_height.html
last_updated: "2026.04.06 오후 02:51"
---

# height

## 객체

> [CapsuleCollider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/CapsuleCollider)

## 설명

이 프로퍼티는 캡슐의 높이를 객체의 로컬 공간에서 측정한 값을 반환합니다. 높이는 캡슐의 물리적 특성을 정의하는 데 사용되며, 물체의 충돌 및 상호작용에 영향을 미칠 수 있습니다.

높이를 설정할 때는 유효한 값(0 이상의 값)을 입력해야 하며, 음수 값은 예외를 발생시킬 수 있습니다. 이 프로퍼티는 읽기 및 쓰기가 가능하므로, 필요에 따라 동적으로 캡슐의 높이를 조정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `height`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local height = capsuleCollider.height
capsuleCollider.height = newHeight
```

## 참고 사항

동기화 지원
