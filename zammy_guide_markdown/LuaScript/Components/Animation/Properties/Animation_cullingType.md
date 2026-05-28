---
title: cullingType
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Properties/Animation_cullingType
source_path: LuaScript/Components/Animation/Properties/Animation_cullingType.html
last_updated: "2026.04.06 오후 02:48"
---

# cullingType

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

이 프로퍼티는 Animation 컴포넌트의 컬링(culling) 방식을 제어합니다. 컬링은 화면에 보이지 않는 객체의 애니메이션을 비활성화하여 성능을 최적화하는 데 사용됩니다. 이 프로퍼티는 애니메이션이 항상 실행되도록 하거나, 렌더러의 가시성에 따라 애니메이션을 조정할 수 있습니다.

지원하는 값은 다음과 같습니다:

- `AlwaysAnimate`: 애니메이션 컬링이 비활성화되어, 객체가 화면에 없더라도 애니메이션이 실행됩니다.
- `BasedOnRenderers`: 렌더러가 보이지 않을 때 애니메이션이 비활성화됩니다.
- `BasedOnClipBounds`: 클립 경계에 따라 애니메이션이 조정됩니다.
- `BasedOnUserBounds`: 사용자 경계에 따라 애니메이션이 조정됩니다.

이 프로퍼티는 애니메이션의 성능을 최적화하는 데 유용하며, 적절한 값을 설정하여 필요에 따라 애니메이션의 실행 여부를 조정할 수 있습니다.

## 프로퍼티 정의

- **이름**: `cullingType`
- **타입**: `AnimationCullingType`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
value = Animation.cullingType
Animation.cullingType = value
```

## 참고 사항

동기화 미지원
