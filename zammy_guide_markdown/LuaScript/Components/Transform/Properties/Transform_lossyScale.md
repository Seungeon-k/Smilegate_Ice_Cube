---
title: lossyScale
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Properties/Transform_lossyScale
source_path: LuaScript/Components/Transform/Properties/Transform_lossyScale.html
last_updated: "2026.04.06 오후 02:58"
---

# lossyScale

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 프로퍼티는 객체의 전역 스케일을 반환합니다. 이 값은 읽기 전용이며, 객체의 크기를 조정하는 데 사용됩니다. 이 프로퍼티는 변형(Transform) 컴포넌트의 스케일을 기반으로 하며, 부모 객체의 스케일도 포함하여 계산됩니다.

이 프로퍼티는 설정할 수 없으므로, 값을 변경하려고 하면 예외가 발생하지 않지만, 무시됩니다. 따라서 이 프로퍼티를 통해 객체의 현재 스케일을 확인하는 용도로만 사용해야 합니다.

## 프로퍼티 정의

- **이름**: `lossyScale`
- **타입**: [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local scale = transform.lossyScale
```

## 참고 사항

동기화 미지원
