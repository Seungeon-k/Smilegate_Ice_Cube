---
title: BounceAt
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_BounceAt_PenguinCharacterVo_Vector3__A468602544
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_BounceAt_PenguinCharacterVo_Vector3__A468602544.html
last_updated: "2026.04.06 오후 03:34"
---

# BounceAt

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`BounceAt`는 충돌 지점(hitPosition)을 기준으로 캐릭터에 반발(튕김) 힘을 가합니다.  

피격 반응, 반동, 장애물 충돌 시 튕겨 나가는 연출처럼 “어느 지점에서 맞았는지”를 반영한 물리 반응을 만들 때 사용합니다.

## 함수

BounceAt(force, hitPosition, forceMode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | force | 캐릭터에 가할 힘(또는 임펄스) 벡터입니다. 방향은 튕겨 나가는 방향, 크기는 튕김 강도를 의미합니다. |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | hitPosition | 힘을 적용할 기준 위치(충돌 지점)입니다. 캐릭터의 어느 지점에서 힘이 작용하는지에 따라 반동 체감이 달라질 수 있습니다. |
| [`ForceMode`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/ForceMode) | forceMode | 힘 적용 방식입니다. 연출 목적에 맞게 지속 힘/순간 힘(임펄스) 등 원하는 모드를 선택합니다 |

### 반환값

없음.

## 예제 코드

```lua
function this.BounceFromHit(penguin, hitPos, dir)
    -- dir은 튕겨 나갈 방향(정규화 권장)이라고 가정
    local force = dir * 12
    penguin:BounceAt(force, hitPos, ForceMode.Impulse)
end
```
