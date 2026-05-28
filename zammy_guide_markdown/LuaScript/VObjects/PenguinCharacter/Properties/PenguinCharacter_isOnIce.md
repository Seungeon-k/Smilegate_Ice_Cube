---
title: isOnIce
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isOnIce
source_path: LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isOnIce.html
last_updated: "2026.04.06 오후 03:35"
---

# isOnIce

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`isOnIce`는 캐릭터가 미끄러짐 연출/이동 상태가 적용 중인지를 나타냅니다.  

true인 동안에는 미끄러짐 상태로 간주되며, 펭귄 전용 슬라이딩 연출(파티클, 사운드 등)이 발생합니다.

## 프로퍼티 정의

- **이름**: isOnIce
- **타입**: boolean
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
function this.CheckIceState(penguin)
    if penguin.isOnIce then
        print("The penguin is sliding on ice!")
    end
end
```
