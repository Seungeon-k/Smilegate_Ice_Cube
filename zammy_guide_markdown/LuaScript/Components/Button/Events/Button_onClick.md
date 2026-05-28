---
title: onClick
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Button/Events/Button_onClick
source_path: LuaScript/Components/Button/Events/Button_onClick.html
last_updated: "2026.04.06 오후 02:50"
---

# onClick

## 객체

> [Button](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Button)

## 설명

`onClick`은 버튼 클릭 입력이 확정되는 시점에 호출되는 이벤트입니다.  

확인/취소 버튼 처리, UI 전환, 서비스 요청 시작처럼 사용자 의도를 실제 실행 로직으로 넘길 때 사용합니다.  

같은 버튼을 빠르게 연속 입력하는 상황에서는 중복 요청이 발생하지 않도록 잠금 플래그나 비활성화 처리를 함께 두는 것이 안전합니다.

## 프로퍼티 정의

- **이름**: `onClick`
- **타입**: `ButtonClickedEvent`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local isSubmitting = false

function this.OnStart()
    local button = this.scriptObject:GetComponent("Button")
    if button ~= nil then
        button.onClick:AddListener(this.OnSubmitClicked)
    end
end

function this.OnSubmitClicked()
    if isSubmitting then
        return
    end

    isSubmitting = true
    this.scriptObject:Log("submit clicked")
    this.OpenConfirmPopup()
end
```

## 참고 사항

버튼이 비활성화(`interactable = false`) 상태일 때는 `onClick`이 발생하지 않습니다.
