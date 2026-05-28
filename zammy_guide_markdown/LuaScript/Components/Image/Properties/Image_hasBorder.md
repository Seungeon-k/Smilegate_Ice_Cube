---
title: hasBorder
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_hasBorder
source_path: LuaScript/Components/Image/Properties/Image_hasBorder.html
last_updated: "2026.04.06 오후 02:52"
---

# hasBorder

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지에 테두리가 있는지를 나타냅니다. 테두리가 있는 경우 true를 반환하고, 그렇지 않은 경우 false를 반환합니다. 이 프로퍼티는 읽기 전용이며, 값을 설정할 수 없습니다. 사용 시 주의해야 할 점은 이 프로퍼티를 통해 테두리의 존재 여부를 확인할 수 있지만, 직접적으로 값을 변경할 수는 없다는 것입니다.

## 프로퍼티 정의

- **이름**: `hasBorder`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local hasBorder = image.hasBorder
```

## 참고 사항

동기화 미지원
