---
title: InverseTransformVector
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_InverseTransformVector
source_path: LuaScript/Components/Transform/Methods/Transform_InverseTransformVector.html
last_updated: "2026.04.06 오후 02:57"
---

# InverseTransformVector

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 함수는 월드 공간에서 로컬 공간으로 벡터를 변환합니다. 이는 `Transform.TransformVector`의 반대 작업입니다. 사용 시 주의할 점은 입력 벡터가 월드 공간에서의 위치를 기준으로 해야 한다는 것입니다. 반환된 벡터는 해당 객체의 로컬 공간에서의 위치를 나타냅니다.

`InverseTransformVector`는 `Transform`의 핵심 동작을 실행합니다. 호출 전 대상 유효성 검증과 후속 처리 순서를 명확히 두세요.  

`InverseTransformVector`는 월드 기준 방향 벡터를 현재 Transform의 로컬 축 기준 벡터로 변환합니다. 위치 좌표 변환이 아니라 방향/속도 변환 용도이므로, 이동량 계산 시 `TransformPoint` 계열과 혼용하지 않도록 주의하세요.  

`InverseTransformVector`를 여러 스크립트가 동시에 호출하면 결과가 덮어써질 수 있으므로, 호출 주체를 명확히 분리해 관리하세요.

## 함수

InverseTransformVector(vector)  
  

InverseTransformVector(x, y, z)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `vector` | 변환할 벡터 |
| `number` | `x` | x 좌표 값 |
| `number` | `y` | y 좌표 값 |
| `number` | `z` | z 좌표 값 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| [Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | 변환된 결과 벡터 |

[Vector3](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) 결과를 반환합니다. 반환 객체의 유효 상태를 확인한 뒤 후속 처리에 사용하세요.

## 예제 코드

```lua
function this.OnStart()
    local target = this.scriptObject
    local localDir = target:InverseTransformVector(0, 0, 1)
    this.scriptObject:Log("local direction = " .. tostring(localDir))
end
```
