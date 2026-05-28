---
title: useSpriteMesh
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_useSpriteMesh
source_path: LuaScript/Components/Image/Properties/Image_useSpriteMesh.html
last_updated: "2026.04.06 오후 02:52"
---

# useSpriteMesh

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 스프라이트 메쉬 사용 여부를 설정합니다. 스프라이트 메쉬를 사용하면 스프라이트의 모양을 더 정밀하게 표현할 수 있습니다. 이 프로퍼티를 통해 스프라이트의 메쉬 사용을 활성화하거나 비활성화할 수 있습니다.

스프라이트 메쉬를 사용할 경우, 스프라이트의 렌더링 성능에 영향을 줄 수 있으므로, 필요에 따라 적절히 설정해야 합니다. 이 프로퍼티는 읽기 및 쓰기가 가능하며, 기본값은 false입니다.

## 프로퍼티 정의

- **이름**: `useSpriteMesh`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
image.useSpriteMesh
```

## 참고 사항

동기화 미지원
