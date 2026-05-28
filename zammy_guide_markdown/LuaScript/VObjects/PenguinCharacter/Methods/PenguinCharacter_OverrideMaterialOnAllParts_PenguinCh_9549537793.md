---
title: OverrideMaterialOnAllParts
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_OverrideMaterialOnAllParts_PenguinCh_9549537793
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_OverrideMaterialOnAllParts_PenguinCh_9549537793.html
last_updated: "2026.04.06 오후 03:34"
---

# OverrideMaterialOnAllParts

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`OverrideMaterialOnAllParts`는 펭귄 캐릭터를 구성하는 모든 파츠(바디/의상/액세서리 등)의 렌더러 머터리얼을 지정한 머터리얼로 일괄 교체합니다.  

상태 이상(얼음/화상), 이벤트 스킨 연출처럼 캐릭터 전체 외형을 동일한 머터리얼로 덮어써야 하는 상황에서 사용합니다.

## 함수

OverrideMaterialOnAllParts(material)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Material`](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/Material_Resource) | material | 모든 파츠에 적용할 대상 머터리얼입니다. 호출 시 캐릭터가 사용하는 각 파츠의 머터리얼이 해당 머터리얼로 오버라이드됩니다. |

### 반환값

없음.

## 예제 코드

```lua
function this.ApplyHitMaterial(penguin, buffMaterial)
    penguin:OverrideMaterialOnAllParts(buffMaterial)
end
```
