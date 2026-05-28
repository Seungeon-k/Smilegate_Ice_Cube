---
title: color
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshPro/Properties/TextMeshPro_color
source_path: LuaScript/Components/TextMeshPro/Properties/TextMeshPro_color.html
last_updated: "2026.04.06 오후 02:56"
---

# color

## 객체

> [TextMeshPro](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshPro)

## 설명

이 프로퍼티는 텍스트의 색상을 설정하거나 가져오는 데 사용됩니다. 색상은 `Color` 타입으로 표현되며, RGB 및 알파 값을 포함합니다. 이 프로퍼티를 통해 텍스트의 시각적 표현을 조정할 수 있습니다.

색상을 설정할 때는 `Color` 객체를 사용해야 하며, 잘못된 값이 입력될 경우 예외가 발생할 수 있습니다. 이 프로퍼티는 동기화를 지원하지 않으므로, 멀티스레드 환경에서의 사용에 주의해야 합니다.

## 프로퍼티 정의

- **이름**: `color`
- **타입**: `Color`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
text.color = Color(r, g, b, a)
local currentColor = text.color
```

## 참고 사항
