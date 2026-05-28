---
title: fillCenter
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_fillCenter
source_path: LuaScript/Components/Image/Properties/Image_fillCenter.html
last_updated: "2026.04.06 오후 02:52"
---

# fillCenter

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

`fillCenter` 프로퍼티는 이미지의 중앙을 채우는 여부를 설정합니다. 이 프로퍼티를 사용하면 이미지의 중앙 부분이 채워질지 여부를 제어할 수 있습니다.

이 프로퍼티는 Boolean 타입으로, `true`일 경우 중앙이 채워지고, `false`일 경우 중앙이 비어 있게 됩니다.

사용 시 주의할 점은, 이 프로퍼티가 동기화를 지원하지 않기 때문에 멀티스레드 환경에서의 사용은 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `fillCenter`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
local fillCenterValue = image.fillCenter
image.fillCenter = true
```

## 참고 사항

동기화 미지원
