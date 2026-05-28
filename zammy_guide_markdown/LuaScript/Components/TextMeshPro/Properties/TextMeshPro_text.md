---
title: text
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshPro/Properties/TextMeshPro_text
source_path: LuaScript/Components/TextMeshPro/Properties/TextMeshPro_text.html
last_updated: "2026.04.06 오후 02:56"
---

# text

## 객체

> [TextMeshPro](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshPro)

## 설명

이 프로퍼티는 텍스트 객체의 내용을 문자열 형태로 설정하거나 가져오는 데 사용됩니다. 텍스트를 변경하면 해당 객체에 표시되는 내용이 즉시 업데이트됩니다.

이 프로퍼티는 읽기와 쓰기가 모두 가능하므로, 텍스트를 동적으로 변경할 수 있습니다. 그러나 동기화는 지원하지 않으므로, 멀티스레드 환경에서의 사용은 주의가 필요합니다.

## 프로퍼티 정의

- **이름**: `text`
- **타입**: `string`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
text = tmpText.text

tmpText.text = "새로운 텍스트"
```

## 참고 사항
