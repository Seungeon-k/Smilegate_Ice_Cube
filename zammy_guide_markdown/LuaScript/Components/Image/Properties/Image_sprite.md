---
title: sprite
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_sprite
source_path: LuaScript/Components/Image/Properties/Image_sprite.html
last_updated: "2026.04.06 오후 02:52"
---

# sprite

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 스프라이트를 설정하거나 가져오는 데 사용됩니다. 스프라이트는 2D 그래픽을 표현하는 데 필요한 이미지 데이터입니다. 이 프로퍼티를 통해 스프라이트를 동적으로 변경할 수 있으며, 이를 통해 다양한 비주얼 효과를 구현할 수 있습니다.

스프라이트를 설정할 때는 유효한 스프라이트 객체를 제공해야 하며, 잘못된 객체를 설정할 경우 예외가 발생할 수 있습니다. 또한, 스프라이트가 변경되면 해당 이미지를 사용하는 모든 요소에 즉시 반영됩니다.

## 프로퍼티 정의

- **이름**: `sprite`
- **타입**: `Sprite`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
image.sprite = sprite
local currentSprite = image.sprite
```

## 참고 사항

동기화 미지원
