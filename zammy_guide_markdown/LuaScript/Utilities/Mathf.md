---
title: Mathf
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Mathf
source_path: LuaScript/Utilities/Mathf.html
last_updated: "2026.04.06 오후 03:30"
---

# Mathf

## 개요

Mathf는 수학 연산을 위해 제공되는 정적(Static) 유틸리티 클래스입니다.  

삼각함수, 반올림, 보간, 각도 처리, 범위 제한, 부동소수 안정 비교, 감속(SmoothDamp) 등  

게임 개발에서 자주 필요한 수학 기능들을 제공합니다.

## 속성

| 이름 | 타입 | 설명 | 읽기 | 쓰기 |
| --- | --- | --- | --- | --- |
| `PI` | `number` | 원주율 π | ✅ | ❌ |
| `Deg2Rad` | `number` | 1도를 라디안으로 변환하는 상수 | ✅ | ❌ |
| `Rad2Deg` | `number` | 1라디안을 도(degree)로 변환하는 상수 | ✅ | ❌ |
| `Infinity` | `number` | 양의 무한대 | ✅ | ❌ |
| `NegativeInfinity` | `number` | 음의 무한대 | ✅ | ❌ |
| `Epsilon` | `number` | 매우 작은 부동소수(float) 값 | ✅ | ❌ |

## 메서드

| 메서드명 | 설명 | 반환값 |
| --- | --- | --- |
| `Abs` | 절댓값을 반환합니다 | number |
| `Sign` | 값의 부호(-1, 0, 1)를 반환합니다. | number |
| `Clamp` | value를 min~max 범위로 제한합니다. | number |
| `Clamp01` | value를 0~1 범위로 제한합니다. | number |
| `Max` | 두 값 중 큰 값을 반환합니다. | number |
| `Min` | 두 값 중 작은 값을 반환합니다. | number |
| `Round` | 반올림한 값을 반환합니다. | number |
| `IsNan` | 값이 NaN인지 확인합니다. | number |
| `Approximately` | 두 값이 거의 같은지 비교합니다. | boolean |
| `Lerp` | 선형 보간을 수행합니다. | number |
| `LerpUnclamped` | clamp 없이 보간합니다. | number |
| `LerpAngle` | 각도 기반 보간을 수행합니다. | number |
| `InverseLerp` | value가 from~to 사이의 몇 %인지 반환합니다. | number |
| `Repeat` | t를 반복 가능한 값으로 만듭니다. | number |
| `PingPong` | PingPong 패턴의 값을 반환합니다. | number |
| `DeltaAngle` | 두 각도의 최소 차이를 구합니다. | number |
| `MoveTowards` | 값을 target 방향으로 일정 속도로 이동합니다. | number |
| `MoveTowardsAngle` | 각도 기반 MoveTowards 기능 | number |
| `SmoothDamp` | 부드럽게 감속·수렴하는 값을 계산합니다. | number, number |
| `SmoothDampAngle` | 각도 SmoothDamp 기능 | number, number |
| `SmoothStep` | 부드러운 S-curve 보간 | number |
| `Gamma` | 감마 보정을 적용합니다. | number |
| `HorizontalAngle` | XZ 평면 기준 수평 각도(도 단위)를 반환합니다. | number |

## 예제 코드

```lua
local v = Mathf.Clamp(10, 0, 5)
print(v) -- 5

local deg = 90 * Mathf.Deg2Rad
print(deg)

local val = Mathf.Lerp(0, 100, 0.25)
print(val) -- 25
```
