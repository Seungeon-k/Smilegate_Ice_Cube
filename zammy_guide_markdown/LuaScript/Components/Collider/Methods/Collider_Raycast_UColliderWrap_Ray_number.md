---
title: Raycast
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider/Methods/Collider_Raycast_UColliderWrap_Ray_number
source_path: LuaScript/Components/Collider/Methods/Collider_Raycast_UColliderWrap_Ray_number.html
last_updated: "2026.04.06 오후 02:51"
---

# Raycast

## 객체

> [Collider](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Collider)

## 설명

이 함수는 주어진 Ray를 발사하여 해당 Collider와의 충돌 여부를 확인합니다. 이때 다른 모든 Collider는 무시됩니다. 반환값이 true일 경우, hitInfo 매개변수는 충돌 지점에 대한 추가 정보를 포함합니다. 최대 거리인 maxDistance를 설정하여 Ray의 길이를 제한할 수 있습니다.

## 함수

Raycast(ray, maxDistance)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Ray`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Ray) | `ray` | Ray의 시작점과 방향을 정의 |
| `number` | `maxDistance` | Ray의 최대 길이를 설정 |

### 반환값

| **형식** | **설명** |
| --- | --- |
| Raycast | 충돌이 발생할 경우, hitInfo는 충돌 지점에 대한 정보 |
| boolean | 충돌 여부 |

## 예제 코드

```lua
local result, hitInfo = Collider:Raycast(ray, maxDistance)
```
