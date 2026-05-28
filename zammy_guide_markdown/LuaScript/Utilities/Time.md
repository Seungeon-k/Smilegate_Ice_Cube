---
title: Time
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Time
source_path: LuaScript/Utilities/Time.html
last_updated: "2026.04.06 오후 03:30"
---

# Time

## 개요

Time 모듈은 게임 루프의 시간 흐름에 관련된 정보를 제공하는 시스템으로,  

프레임 간 경과 시간, 실시간, 고정 업데이트 시간, 타임스케일 조절 등을 관리합니다.

## 속성

| 이름 | 타입 | 설명 | 읽기 | 쓰기 |
| --- | --- | --- | --- | --- |
| `deltaTime` | `number` | 이전 프레임 대비 경과 시간 (timeScale 적용됨) | ✅ | ❌ |
| `unscaledDeltaTime` | `number` | timeScale 영향을 받지 않는 deltaTime | ✅ | ❌ |
| `fixedDeltaTime` | `number` | FixedUpdate 호출 주기(고정 시간 간격) | ✅ | ❌ |
| `maximumDeltaTime` | `number` | deltaTime이 이 값을 초과하면 제한됨 | ✅ | ❌ |
| `time` | `number` | 게임 시작 이후 누적된 시간 (timeScale 적용) | ✅ | ❌ |
| `unscaledTime` | `number` | timeScale과 무관한 실제 누적 시간 | ✅ | ❌ |
| `fixedTime` | `number` | Fixed 업데이트에서의 누적 시간 | ✅ | ❌ |
| `realtimeSinceStartup` | `number` | 앱 시작 이후 실제 경과 시간 | ✅ | ❌ |
| `timeSinceLevelLoad` | `number` | 현재 씬 로드 이후 경과한 시간 | ✅ | ❌ |
| `timeScale` | `number` | 전체 게임 속도를 조절하는 스케일 값 | ✅ | ❌ |
| `frameCount` | `number` | 현재까지 렌더링된 프레임 수 | ✅ | ❌ |

## 예제 코드

```lua
function Update()
    local dt = Time.deltaTime
    x = x + speed * dt
end
```
