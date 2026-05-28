---
title: Play
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/VTween/Methods/VTween_Play_VTween
source_path: LuaScript/Components/VTween/Methods/VTween_Play_VTween.html
last_updated: "2026.04.06 오후 02:58"
---

# Play

## 객체

> [VTween](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/VTween)

## 설명

Play는 설정된 트윈(VTween) 애니메이션을 즉시 시작하는 함수입니다.  

트윈의 duration, target 값(예: 위치, 회전, 스케일), 이징(Ease) 정보 등 셋팅되어 있는 정보를 가지고  

Play() 호출과 함께 트윈이 실행되며, OnTweenStart 이벤트가 즉시 발생합니다.

## 함수

Play()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
local tween = someTween
-- 트윈 실행
tween:Play()
```
