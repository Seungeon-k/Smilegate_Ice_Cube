---
title: SetParent
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject/Methods/VObject_SetParent_VObject_GameEntity
source_path: LuaScript/VObjects/VObject/Methods/VObject_SetParent_VObject_GameEntity.html
last_updated: "2026.04.06 오후 03:37"
---

# SetParent

## 객체

> [VObject](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/VObject)

## 설명

SetParent는 현재 오브젝트의 부모를 지정된 VObject로 설정합니다.  
  

이 메서드를 통해 하이어라키 구조를 재구성할 수 있으며, 기존 부모와의 연결이 끊기고 새로운 부모의 자식으로 편입됩니다.  
  

트랜스폼 정보(위치, 회전, 스케일)는 기본적으로 월드 좌표 기준을 유지하도록 처리되며, 내부 동기화가 자동으로 이루어집니다.  
  

부모 설정에 성공하면 true를 반환하며, 잘못된 부모 지정(예: 자기 자신을 부모로 지정하거나 순환 참조 발생 혹은 부모로 지정할 수 없는 객체) 시 false를 반환합니다.

## 함수

SetParent(vObject)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| GameEntity | vObject | 부모로 설정할 대상 VObject입니다. nil을 전달하면 현재 부모로부터 분리되어 루트로 이동합니다. |

### 반환값

없음

## 예제 코드

```lua
local parentObject = someParent
local childObject = someChild

childObject:SetParent(parentObject)
```
