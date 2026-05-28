---
title: Translate
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform/Methods/Transform_Translate
source_path: LuaScript/Components/Transform/Methods/Transform_Translate.html
last_updated: "2026.04.06 오후 02:57"
---

# Translate

## 객체

> [Transform](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Transform)

## 설명

이 메서드는 변환을 주어진 방향과 거리만큼 이동시킵니다. `translation` 매개변수는 이동할 방향과 거리를 정의하는 벡터입니다. 이 메서드는 변환의 위치를 직접 변경하므로, 호출 후에는 변환의 새로운 위치가 반영됩니다.

이 함수는 주어진 방향과 거리만큼 변환을 이동시킵니다. `translation` 매개변수는 이동할 벡터를 정의하며, `relativeTo` 매개변수는 이동이 적용될 좌표계의 기준을 설정합니다. `relativeTo`가 `World`일 경우 월드 좌표계에 상대적으로 이동하며, `Self`일 경우 로컬 좌표계에 상대적으로 이동합니다.

이 함수는 주어진 방향과 거리만큼 변환을 이동시킵니다. `translation` 매개변수는 이동할 벡터를 정의하며, `relativeTo` 매개변수는 이동할 기준이 되는 변환을 지정합니다. 이 함수는 주로 객체의 위치를 변경할 때 사용됩니다.

이 메서드는 변환을 지정된 방향과 거리만큼 이동시킵니다. x, y, z 인수를 통해 이동할 거리를 설정할 수 있습니다. 이 메서드는 물체의 현재 위치를 기준으로 이동하며, 이동 후의 위치는 자동으로 업데이트됩니다. 인수는 실수형으로, 이동할 거리의 값을 설정합니다.

이 함수는 변환을 지정된 방향과 거리만큼 이동시킵니다. `x`, `y`, `z` 매개변수는 이동할 거리이며, `relativeTo` 매개변수는 이동이 적용될 좌표계의 기준을 설정합니다. `relativeTo`가 `World`일 경우 세계 좌표계에 상대적으로 이동하고, `Self`일 경우 로컬 좌표계에 상대적으로 이동합니다.

이 함수는 반환값이 없으며, 잘못된 매개변수를 전달할 경우 예외가 발생할 수 있습니다.

이 함수는 변환을 지정된 방향과 거리만큼 이동시킵니다. `x`, `y`, `z` 매개변수는 이동할 거리이며, `relativeTo` 매개변수는 이동 기준이 되는 변환 객체입니다. 이 함수는 상대적인 위치를 기준으로 변환을 이동시키므로, 적절한 `relativeTo` 객체를 제공해야 합니다.

## 함수

Translate(translation)  
  

Translate(translation, relativeTo)  
  

Translate(x, y, z)  
  

Translate(x, y, z, relativeTo)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Vector3`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector3) | `translation` | 이동할 방향과 거리 이동할 벡터 |
| [`Space`](https://developers-zammysmith.onstove.com/ko/LuaScript/Enums/Space) `Transform` | `relativeTo` | 좌표계의 기준 기준 변환 이동 기준 좌표계 기준이 되는 변환 |
| `number` | `x` | 이동할 x 거리 이동 거리 (x축) |
| `number` | `y` | 이동할 y 거리 이동 거리 (y축) |
| `number` | `z` | 이동할 z 거리 이동 거리 (z축) |

### 반환값

없음

## 예제 코드

```lua
Transform:Translate(translation, relativeTo)
```
