---
title: RestoreMaterialOnAllParts
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreMaterialOnAllParts_PenguinCharacterVo
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreMaterialOnAllParts_PenguinCharacterVo.html
last_updated: "2026.04.06 오후 03:35"
---

# RestoreMaterialOnAllParts

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`RestoreMaterialOnAllParts`는 [`OverrideMaterialOnAllParts`](PenguinCharacter_OverrideMaterialOnAllParts_PenguinCh_9549537793.md)로 일괄 오버라이드했던 머터리얼을 해제하고, 펭귄 캐릭터 각 파츠가 원래 사용하던 머터리얼 상태로 복구합니다.  

상태 이상/이벤트 연출처럼 잠시 전체 머터리얼을 교체한 뒤, 연출 종료 시 정상 외형으로 되돌릴 때 사용합니다.

## 함수

RestoreMaterialOnAllParts()

### 매개변수

없음.

### 반환값

없음.

## 예제 코드

```lua
function this.PlayHitEffect(penguin, hitMaterial)
    -- 전체 머터리얼 오버라이드
    penguin:OverrideMaterialOnAllParts(hitMaterial)

    -- (연출 종료 시점)
    penguin:RestoreMaterialOnAllParts()
end
```
