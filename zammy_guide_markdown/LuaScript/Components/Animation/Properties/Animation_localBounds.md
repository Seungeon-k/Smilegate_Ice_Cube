---
title: localBounds
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Properties/Animation_localBounds
source_path: LuaScript/Components/Animation/Properties/Animation_localBounds.html
last_updated: "2026.04.06 오후 02:48"
---

# localBounds

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 프로퍼티는 애니메이션 컴포넌트의 로컬 공간에서의 AABB(Bounding Box)를 반환합니다. 이 값은 애니메이션의 경계 상자를 정의하며, 애니메이션의 크기와 위치를 이해하는 데 유용합니다.

이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 따라서 애니메이션의 경계 상자를 직접 수정할 수는 없지만, 다른 방법으로 애니메이션의 크기를 조정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `localBounds`
- **타입**: [`Bounds`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
localBounds = animationComponent.localBounds
```

## 참고 사항

동기화 미지원
