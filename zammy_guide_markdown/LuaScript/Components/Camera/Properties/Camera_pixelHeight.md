---
title: pixelHeight
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera/Properties/Camera_pixelHeight
source_path: LuaScript/Components/Camera/Properties/Camera_pixelHeight.html
last_updated: "2026.04.06 오후 02:51"
---

# pixelHeight

## 객체

> [Camera](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Camera)

## 설명

`pixelHeight`은(는) 현재 객체 상태를 나타내는 `number` 프로퍼티입니다. 연관 API 호출 전후 상태 판단 기준으로 사용합니다. 후속 로직에서는 값 반영 시점과 참조 유효성을 함께 확인해야 합니다.  

`pixelHeight` 값은 `Camera`의 현재 상태를 직접 반영하므로 초기화/활성화 시점 차이를 고려해 사용 직전에 조회하는 방식이 안전합니다.  

멀티플레이에서는 `pixelHeight`를 로컬 표시용 값과 권한 판정용 값으로 분리하고, 최종 판정은 권한 주체 기준으로 처리해야 상태 불일치를 줄일 수 있습니다.

## 프로퍼티 정의

- **이름**: pixelHeight
- **타입**: number
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.OnStart()
    local value = this.scriptObject.pixelHeight
    this.scriptObject:Log(tostring(value))
end
```
