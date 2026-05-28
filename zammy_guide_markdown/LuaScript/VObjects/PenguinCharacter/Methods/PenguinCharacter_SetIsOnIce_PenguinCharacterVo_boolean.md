---
title: SetIsOnIce
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetIsOnIce_PenguinCharacterVo_boolean
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetIsOnIce_PenguinCharacterVo_boolean.html
last_updated: "2026.04.06 오후 03:35"
---

# SetIsOnIce

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`SetIsOnIce`는 펭귄 캐릭터의 빙판(미끄러짐) 상태 플래그를 설정합니다.  

`isOnIce`가 true로 설정되면 캐릭터는 미끄러짐 상태로 간주되며, 빙판 전용 이동/조작감 처리나 슬라이딩 연출(이펙트/사운드 등)을 활성화하는 용도로 사용할 수 있습니다.

## 함수

SetIsOnIce(isOnIce)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `boolean` | isOnIce | 판(미끄러짐) 상태로 설정할지 여부입니다. true면 미끄러짐 상태로 전환되고, false면 일반 상태로 복귀합니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.ApplyIceState(penguin, onIce)
    penguin:SetIsOnIce(onIce)

    if penguin.isOnIce then
        print("The penguin is sliding on ice!")
    else
        print("The penguin is no longer on ice.")
    end
end
```
