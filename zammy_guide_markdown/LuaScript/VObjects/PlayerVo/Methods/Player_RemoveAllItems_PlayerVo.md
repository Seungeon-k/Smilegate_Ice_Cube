---
title: RemoveAllItems
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Methods/Player_RemoveAllItems_PlayerVo
source_path: LuaScript/VObjects/PlayerVo/Methods/Player_RemoveAllItems_PlayerVo.html
last_updated: "2026.04.06 오후 03:36"
---

# RemoveAllItems

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`RemoveAllItems`는 플레이어 현재 보유하고 있는 모든 아이템을 한 번에 제거하는 함수입니다.

개별 아이템을 하나씩 지정하지 않고 전체 아이템 목록을 비울 때 사용합니다.  

주로 캐릭터 초기화, 상태 리셋, 테스트용 정리, 특정 상황에서 전체 아이템 제거가 필요할 때 사용할 수 있습니다.

아이템이 모두 제거된 뒤에는 구현에 따라 장착 상태 해제, 보유 목록 갱신, 관련 이벤트 호출 등의 후속 처리가 함께 이루어질 수 있습니다.

## 함수

RemoveAllItems()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
player:RemoveAllItems()
```

## 참고 사항

- 서버스크립트에서만 동작합니다.
