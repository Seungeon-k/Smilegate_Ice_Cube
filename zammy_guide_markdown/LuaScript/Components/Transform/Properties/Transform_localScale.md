---
title: localScale
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_localScale
source_path: LuaScript/Components/Transform/Properties/Transform_localScale.html
last_updated: "2026.04.06 오후 02:57"
---

# localScale

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 변환의 스케일을 부모 게임 오브젝트에 상대적으로 설정합니다. 스케일은 3D 공간에서 객체의 크기를 조정하는 데 사용됩니다. 이 프로퍼티를 통해 객체의 크기를 동적으로 변경할 수 있으며, 부모 객체의 스케일에 영향을 받습니다.

스케일을 설정할 때는 [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 형식의 값을 사용해야 하며, 각 축(X, Y, Z)의 크기를 조정할 수 있습니다. 스케일 값이 (1, 1, 1)일 경우 기본 크기를 의미합니다. 스케일 값이 0 이하일 경우 객체가 보이지 않거나 비정상적으로 표시될 수 있으므로 주의해야 합니다.

## 프로퍼티 정의

- **이름**: `localScale`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
transform.localScale
```

## 참고 사항

동기화 지원
