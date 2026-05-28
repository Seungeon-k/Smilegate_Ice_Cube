---
title: animatePhysics
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Properties/Animation_animatePhysics
source_path: LuaScript/Components/Animation/Properties/Animation_animatePhysics.html
last_updated: "2026.04.06 오후 02:48"
---

# animatePhysics

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 기능을 켜면 애니메이션이 물리 루프에서 실행됩니다. 이 기능은 운동학적 강체와 함께 사용할 때만 유용합니다.

애니메이션 플랫폼은 그 위에 놓인 강체에 속도와 마찰력을 적용할 수 있습니다. 이를 사용하려면 animatePhysics가 활성화되어 있어야 하며, 애니메이션이 적용된 객체는 운동학적 강체여야 합니다.

## 프로퍼티 정의

- **이름**: `animatePhysics`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
value = animation.animatePhysics
```

## 참고 사항
