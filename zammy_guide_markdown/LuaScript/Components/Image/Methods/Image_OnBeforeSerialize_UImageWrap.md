---
title: OnBeforeSerialize
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Methods/Image_OnBeforeSerialize_UImageWrap
source_path: LuaScript/Components/Image/Methods/Image_OnBeforeSerialize_UImageWrap.html
last_updated: "2026.04.06 오후 02:52"
---

# OnBeforeSerialize

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 메서드는 객체가 직렬화되기 전에 호출됩니다. 주로 객체의 상태를 직렬화하기 전에 필요한 준비 작업을 수행하는 데 사용됩니다. 이 메서드는 매개변수를 받지 않으며, 반환값도 없습니다. 사용 시 주의할 점은 이 메서드가 호출되는 시점에 대한 이해가 필요하다는 것입니다. 직렬화 과정에서 발생할 수 있는 예외 상황에 대한 처리를 고려해야 합니다.

## 함수

OnBeforeSerialize()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
Image:OnBeforeSerialize()
```
