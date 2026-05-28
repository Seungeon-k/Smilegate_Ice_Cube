---
title: OnAfterDeserialize
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Methods/Image_OnAfterDeserialize_UImageWrap
source_path: LuaScript/Components/Image/Methods/Image_OnAfterDeserialize_UImageWrap.html
last_updated: "2026.04.06 오후 02:52"
---

# OnAfterDeserialize

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 메서드는 객체가 역직렬화된 후 호출됩니다. 주로 데이터가 로드된 후 추가적인 초기화 작업을 수행하는 데 사용됩니다. 이 메서드는 인수가 없으며, 반환값도 없습니다. 사용 시 주의할 점은 이 메서드가 자동으로 호출되므로, 수동으로 호출하지 않아야 한다는 것입니다.

## 함수

OnAfterDeserialize()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
Image:OnAfterDeserialize()
```
