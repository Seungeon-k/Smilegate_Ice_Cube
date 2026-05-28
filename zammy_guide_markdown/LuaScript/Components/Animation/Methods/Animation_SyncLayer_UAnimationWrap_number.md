---
title: SyncLayer
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation/Methods/Animation_SyncLayer_UAnimationWrap_number
source_path: LuaScript/Components/Animation/Methods/Animation_SyncLayer_UAnimationWrap_number.html
last_updated: "2026.04.06 오후 02:48"
---

# SyncLayer

## 객체

> [Animation](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animation)

## 설명

지정한 애니메이션 레이어(layer index) 에 속한 모든 애니메이션 클립들의 재생 속도를 동기화(synchronize)합니다.

레이어 안에서 현재 블렌딩 중인 애니메이션들(예: walk, run 등)의 정규화된 재생 속도(normalized playback speed) 들을 각 애니메이션의 블렌드 가중치(blend weight)를 기준으로 평균 내고, 그 평균 속도를 다시 그 레이어의 모든 애니메이션에 적용합니다.

이 과정을 통해 서로 길이(duration)가 다른 루프 애니메이션들 간에도, 예를 들어 걷기와 달리기의 루프 타이밍(발이 땅을 딛는 타이밍 등)을 어느 정도 맞춰줄 수 있게 됩니다.

완전히 동일한 타이밍을 보장하기보다는 블렌딩 중 타이밍 어긋남을 줄이는 보조 수단에 가깝습니다.

## 함수

SyncLayer(layer)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `number` | `layer` | 동기화할 애니메이션 레이어의 인덱스(index) |

### 반환값

없음

## 예제 코드

```lua
animation:SyncLayer(layerIndex)
```
