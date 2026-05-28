---
title: RestoreRigidbodyConstraints
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreRigidbodyConstraints_PenguinCharacterVo
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreRigidbodyConstraints_PenguinCharacterVo.html
last_updated: "2026.04.06 오후 03:35"
---

# RestoreRigidbodyConstraints

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`RestoreRigidbodyConstraints`는 캐릭터 [`Rigidbody`](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Rigidbody)의 제약(Constraints) 상태를 이전 값으로 복구합니다.  

연출/상태 제어를 위해 [`SetRigidbodyConstraints`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/Character/Methods/Character_SetRigidbodyConstraints_CharacterVo_Rigidbo_42BBF92B21) 로 제약을 변경한 뒤, 작업이 끝났을 때 원래 상태로 되돌리는 용도로 사용합니다.

## 함수

RestoreRigidbodyConstraints()

### 매개변수

없음.

### 반환값

없음.

## 예제 코드

```lua
function this.ApplyCutsceneLock(character)
    -- 연출 중 제약 변경
    character:SetRigidbodyConstraints(RigidbodyConstraints.FreezeAll)

    -- 연출 종료 시 원래 제약으로 복구
    character:RestoreRigidbodyConstraints()
end
```
