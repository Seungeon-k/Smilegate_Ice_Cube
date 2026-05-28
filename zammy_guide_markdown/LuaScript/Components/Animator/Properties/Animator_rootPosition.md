---
title: rootPosition
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_rootPosition
source_path: LuaScript/Components/Animator/Properties/Animator_rootPosition.html
last_updated: "2026.04.06 오후 02:49"
---

# rootPosition

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 게임 오브젝트의 루트 위치를 나타냅니다. 루트 위치는 게임 오브젝트의 위치를 정의하며, 이 값을 통해 오브젝트의 위치를 조정할 수 있습니다.

루트 위치는 읽기 전용이며, 직접적으로 설정할 수 없습니다. 따라서 이 프로퍼티를 통해 현재 위치를 가져오는 용도로만 사용해야 합니다.

예외적으로, 루트 위치를 변경하려면 다른 방법을 사용해야 하며, 이 프로퍼티를 통해 직접적으로 변경할 수는 없습니다.

## 프로퍼티 정의

- **이름**: `rootPosition`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local position = animator.rootPosition
```

## 참고 사항

동기화 미지원
