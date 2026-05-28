---
title: SetAngularVelocity
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetAngularVelocity_PenguinCharacterVo_Vector3
source_path: LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetAngularVelocity_PenguinCharacterVo_Vector3.html
last_updated: "2026.04.06 오후 03:35"
---

# SetAngularVelocity

## 객체

> [PenguinCharacter](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PenguinCharacter)

## 설명

`SetAngularVelocity`는 캐릭터의 강체에 적용되는 각속도(angular velocity) 벡터를 설정합니다.  

피격 반응, 회전 연출, 상태 전환 효과 등 물리 기반 회전이 필요한 상황에서 사용합니다.

캐릭터의 동작 상태에 따라 해당 내용이 바로 업데이트가 되어 동작이 되지 않을 수 있습니다.

## 함수

SetAngularVelocity(angularVelocity)

### 매개변수

| 타입 | 이름 | 설명 |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | angularVelocity | 축별 각속도 벡터입니다. 벡터의 방향은 회전 축(및 방향), 크기는 회전 속도를 의미합니다. 현재 물리 상태와 충돌하지 않도록 과도한 값 전달을 피해야 불필요한 회전 누적을 줄일 수 있습니다. |

### 반환값

없음.

## 예제

```lua
function this.ApplySpin(character)
    character:SetAngularVelocity(Vector3(0, 12, 0))
end
```
