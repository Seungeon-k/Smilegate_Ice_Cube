---
title: CancelKnockBack
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_CancelKnockBack_PenguinCharacterVo
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_CancelKnockBack_PenguinCharacterVo.html
last_updated: "2026.04.06 오후 03:34"
---

# CancelKnockBack

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`CancelKnockBack`은 캐릭터에 적용 중인 넉백 처리를 중단합니다.  

[`KnockBack`](PenguinCharacter_KnockBack.md)으로 인해 진행 중인 넉백 상태를 강제로 종료해야 하는 상황(상태 전환, 경직 해제, 컷신 진입, 리스폰/텔레포트, 연출 스킵 등)에서 사용합니다.

## 함수

CancelKnockBack()

### 매개변수

없음.

### 반환값

없음.

## 예제 코드

```lua
function this.InterruptKnockBack(penguin)
    -- 넉백 진행 중이라면 즉시 중단
    penguin:CancelKnockBack()
end
```
