---
title: layoutPriority
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_layoutPriority
source_path: LuaScript/Components/Image/Properties/Image_layoutPriority.html
last_updated: "2026.04.06 오후 02:52"
---

# layoutPriority

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 UI 이미지의 레이아웃 우선 순위를 나타냅니다. 레이아웃 우선 순위는 이미지가 레이아웃 시스템에서 얼마나 우선적으로 배치되는지를 결정합니다. 이 값은 정수형으로, 기본값은 0입니다.

이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 따라서 레이아웃 우선 순위를 변경하려면 다른 방법을 사용해야 합니다.

## 프로퍼티 정의

- **이름**: `layoutPriority`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local priority = image.layoutPriority
```

## 참고 사항

동기화 미지원
