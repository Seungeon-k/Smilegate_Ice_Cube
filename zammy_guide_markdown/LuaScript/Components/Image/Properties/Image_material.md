---
title: material
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_material
source_path: LuaScript/Components/Image/Properties/Image_material.html
last_updated: "2026.04.06 오후 02:52"
---

# material

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 재질(Material)을 가져오거나 설정하는 데 사용됩니다. 재질은 이미지의 시각적 표현을 정의하며, 다양한 효과를 적용할 수 있습니다.

재질을 설정할 때는 유효한 Material 객체를 제공해야 하며, 잘못된 객체를 설정할 경우 예외가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `material`
- **타입**: `Material`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local material = image.material
image.material = newMaterial
```

## 참고 사항

동기화 미지원
