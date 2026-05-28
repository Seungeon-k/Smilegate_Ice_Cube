---
title: NotifyItemAutoUseCompleted
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo/Methods/Item_NotifyItemAutoUseCompleted_ItemVo
source_path: LuaScript/VObjects/ItemVo/Methods/Item_NotifyItemAutoUseCompleted_ItemVo.html
last_updated: "2026.04.06 오후 03:33"
---

# NotifyItemAutoUseCompleted

## 객체

> [Item](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/ItemVo)

## 설명

`NotifyItemAutoUseCompleted`는 자동 사용 아이템의 처리 완료를 아이템 시스템에 통지합니다.  

Item이 아직 사용 중이면 아이템 사용을 강제로 종료하고, 사용중이 아니면 [`OnItemAutoUsed`](https://developers-zammysmith.onstove.com/ko/LuaScript/Services/PlayerService/Events/PlayerService_OnItemAutoUsed) 이벤트를 호출합니다.

## 함수

NotifyItemAutoUseCompleted()

### 매개변수

없음.

### 반환값

없음.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    target:NotifyItemAutoUseCompleted()
end
```
