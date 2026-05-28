---
title: localRotation
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_localRotation
source_path: LuaScript/Components/Transform/Properties/Transform_localRotation.html
last_updated: "2026.04.06 오후 02:57"
---

# localRotation

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 부모의 변환 회전에 상대적인 변환의 회전을 나타냅니다. 이를 통해 객체의 회전을 조정할 수 있으며, 부모 객체의 회전 변화에 따라 자식 객체의 회전도 자동으로 업데이트됩니다.

회전 값은 [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion) 형식으로 반환되며, 이를 통해 3D 공간에서의 회전을 표현할 수 있습니다. 회전 값을 설정할 때는 유효한 [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion) 값을 제공해야 하며, 잘못된 값이 입력될 경우 예외가 발생할 수 있습니다.

## 프로퍼티 정의

- **이름**: `localRotation`
- **타입**: [`Quaternion`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Quaternion)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
localRotation = transform.localRotation
transform.localRotation = newRotation
```

## 참고 사항

동기화 지원
