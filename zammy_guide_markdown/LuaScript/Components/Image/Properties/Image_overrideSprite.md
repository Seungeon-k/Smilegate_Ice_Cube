---
title: overrideSprite
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_overrideSprite
source_path: LuaScript/Components/Image/Properties/Image_overrideSprite.html
last_updated: "2026.04.06 오후 02:52"
---

# overrideSprite

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 오버라이드 스프라이트를 설정하거나 가져오는 데 사용됩니다. 오버라이드 스프라이트를 설정하면 기본 스프라이트 대신 지정한 스프라이트가 표시됩니다. 이 프로퍼티는 스프라이트를 동적으로 변경할 수 있는 유용한 방법을 제공합니다.

사용 시 주의할 점은, 오버라이드 스프라이트가 설정되면 원래의 스프라이트는 더 이상 표시되지 않으므로, 필요에 따라 원래 스프라이트를 저장해 두는 것이 좋습니다.

## 프로퍼티 정의

- **이름**: `overrideSprite`
- **타입**: `Sprite`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
image.overrideSprite
```

## 참고 사항

동기화 미지원
