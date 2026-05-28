---
title: layerCount
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Properties/Animator_layerCount
source_path: LuaScript/Components/Animator/Properties/Animator_layerCount.html
last_updated: "2026.04.06 오후 02:49"
---

# layerCount

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

이 프로퍼티는 애니메이터 컨트롤러의 레이어 수를 반환합니다. 레이어 수는 애니메이션의 복잡성을 조절하는 데 중요한 요소입니다. 이 값은 읽기 전용이며, 설정할 수 없습니다.

애니메이터가 활성화된 상태에서만 유효한 값을 반환하며, 비활성 상태에서는 0을 반환할 수 있습니다. 이 프로퍼티를 사용하여 애니메이션 레이어를 동적으로 관리할 수 있습니다.

## 프로퍼티 정의

- **이름**: `layerCount`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local layerCount = animator.layerCount
```

## 참고 사항

동기화 미지원
