---
title: localPosition
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_localPosition
source_path: LuaScript/Components/Transform/Properties/Transform_localPosition.html
last_updated: "2026.04.06 오후 02:57"
---

# localPosition

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 부모 변환에 상대적인 변환의 위치를 나타냅니다. `localPosition`을 사용하여 객체의 위치를 설정하거나 가져올 수 있습니다. 이 값은 부모 변환의 좌표계를 기준으로 하며, 부모가 이동하면 자식의 `localPosition`은 변하지 않습니다.

`localPosition`을 설정할 때는 [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 타입의 값을 사용해야 하며, 잘못된 타입을 입력할 경우 예외가 발생할 수 있습니다. 또한, 이 프로퍼티는 부모가 없는 경우에도 사용할 수 있습니다.

## 프로퍼티 정의

- **이름**: `localPosition`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
transform.localPosition
```

## 참고 사항

동기화 지원
