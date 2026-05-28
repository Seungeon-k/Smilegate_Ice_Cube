---
title: OnTweenComplete
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/VTween/Events/VTween_OnTweenComplete
source_path: LuaScript/Components/VTween/Events/VTween_OnTweenComplete.html
last_updated: "2026.04.06 오후 02:58"
---

# OnTweenComplete

## 객체

> [VTween](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/VTween)

## 설명

OnTweenComplete는 트윈(VTween) 애니메이션이 모든 동작을 완료했을 때 호출되는 이벤트입니다.

## 프로퍼티 정의

- **이름**: `OnTweenComplete`
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
    tween.OnTweenComplete:AddListener(this.OnTweenComplete)
end

function this.OnTweenComplete(tween)
    print("tween이 종료 되었습니다.")
end
```
