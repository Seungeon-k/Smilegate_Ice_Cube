---
title: mainTexture
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_mainTexture
source_path: LuaScript/Components/Image/Properties/Image_mainTexture.html
last_updated: "2026.04.06 오후 02:52"
---

# mainTexture

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

`mainTexture`는 이미지의 주 텍스처를 반환합니다. 이 프로퍼티는 읽기 전용이며, 텍스처를 설정할 수는 없습니다. 주 텍스처는 이미지의 시각적 표현에 중요한 역할을 하며, 이 프로퍼티를 통해 현재 설정된 텍스처를 확인할 수 있습니다.

이 프로퍼티를 사용할 때는 텍스처가 유효한지 확인하는 것이 좋습니다. 만약 텍스처가 null인 경우, 이미지가 표시되지 않을 수 있습니다.

## 프로퍼티 정의

- **이름**: `mainTexture`
- **타입**: `Texture`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local texture = image.mainTexture
```

## 참고 사항

동기화 미지원
