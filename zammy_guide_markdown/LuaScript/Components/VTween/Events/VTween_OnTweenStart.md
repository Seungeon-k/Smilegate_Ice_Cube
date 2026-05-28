---
title: OnTweenStart
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/VTween/Events/VTween_OnTweenStart
source_path: LuaScript/Components/VTween/Events/VTween_OnTweenStart.html
last_updated: "2026.04.06 오후 02:58"
---

# OnTweenStart

## 객체

> [VTween](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/VTween)

## 설명

OnTweenStart는 트윈(VTween) 애니메이션이 처음 실행되는 순간 발생하는 이벤트입니다.  

트윈이 Play()로 시작될 때 즉시 호출되며, 트윈의 시작 타이밍에 맞춰 연출 초기화, 사운드 재생, UI 활성화 등 필요한 작업을 처리할 때 유용합니다.

## 프로퍼티 정의

- **이름**: `OnTweenStart`
- **타입**: [`TweenEvent`](https://developers-zammysmith.onstove.com/ko/LuaScript/Events/TweenEvent)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject
    local p = script.parent
    local tween = p:GetComponent("VTween")
    tween.OnTweenStart:AddListener(this.OnTweenStart)
end

function this.OnTweenStart(tween)
    print("tween이 시작 되었습니다.")
end
```
