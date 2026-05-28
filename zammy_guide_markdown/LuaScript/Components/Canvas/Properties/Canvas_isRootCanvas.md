---
title: isRootCanvas
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas/Properties/Canvas_isRootCanvas
source_path: LuaScript/Components/Canvas/Properties/Canvas_isRootCanvas.html
last_updated: "2026.04.06 오후 02:51"
---

# isRootCanvas

## 객체

> [Canvas](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Canvas)

## 설명

이 프로퍼티는 현재 캔버스가 루트 캔버스인지 여부를 나타냅니다. 루트 캔버스는 UI 요소의 최상위 컨테이너로, 다른 캔버스의 부모가 될 수 없습니다. 이 프로퍼티는 읽기 전용이며, 설정할 수 없습니다. 루트 캔버스는 UI 시스템에서 중요한 역할을 하므로, 이를 확인하는 것이 필요할 수 있습니다.

## 프로퍼티 정의

- **이름**: `isRootCanvas`
- **타입**: `boolean`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
isRootCanvas = Canvas.isRootCanvas
```

## 참고 사항
