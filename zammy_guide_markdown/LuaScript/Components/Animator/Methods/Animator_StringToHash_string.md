---
title: StringToHash
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator/Methods/Animator_StringToHash_string
source_path: LuaScript/Components/Animator/Methods/Animator_StringToHash_string.html
last_updated: "2026.04.06 오후 02:48"
---

# StringToHash

## 객체

> [Animator](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Animator)

## 설명

StringToHash는 애니메이터 파라미터 이름(문자열)을 숫자 해시 값으로 변환하는 정적 함수입니다.  

해시 값을 사용하면 문자열 비교보다 빠르게 Animator 파라미터를 조회할 수 있으며,  

애니메이션 파라미터를 자주 접근하는 경우 성능 최적화에 도움이 됩니다.  

Animator의 인스턴스 함수가 아니라, Animator 클래스에 속한 정적(static) 유틸리티 함수입니다.

## 함수

StringToHash()

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| string | name | 해시로 변환할 Animator 파라미터 이름입니다. |

### 반환값

| **형식** | **설명** |
| --- | --- |
| number | 입력 문자열을 기반으로 생성된 해시 값입니다. Animator 파라미터 조회에 사용됩니다. |

## 예제 코드

```lua
local hashWalk = Animator.StringToHash("Walk")
```
