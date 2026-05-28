---
title: transform
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/UIObject/Properties/UIObject_transformWrap
source_path: LuaScript/VObjects/UIObject/Properties/UIObject_transformWrap.html
last_updated: "2026.04.06 오후 03:37"
---

# transform

## 객체

> [UIObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/UIObject)

## 설명

이 프로퍼티는 UI 오브젝트의 위치, 크기, 회전, 스케일을 제어하는 트랜스폼(Transform)를 나타냅니다.

## 프로퍼티 정의

- **이름**: `transform`
- **타입**: `Transform`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
    local panel = someUIObject

    -- 패널을 화면 중앙으로 이동
    panel.transform.localPosition = Vector3(0, 0, 0)
```
