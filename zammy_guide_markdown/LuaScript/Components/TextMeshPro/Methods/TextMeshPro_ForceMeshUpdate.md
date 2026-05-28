---
title: ForceMeshUpdate
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshPro/Methods/TextMeshPro_ForceMeshUpdate
source_path: LuaScript/Components/TextMeshPro/Methods/TextMeshPro_ForceMeshUpdate.html
last_updated: "2026.04.06 오후 02:56"
---

# ForceMeshUpdate

## 객체

> [TextMeshPro](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/TextMeshPro)

## 설명

텍스트 오브젝트의 메시를 즉시 다시 생성하는 메서드입니다.  

일반적인 갱신 타이밍을 기다리지 않고, 변경된 텍스트 정보가 바로 반영되도록 강제로 업데이트합니다.

## 함수

ForceMeshUpdate()

### 매개변수

없음

### 반환값

없음

## 예제 코드

```lua
-- TextMeshPro 사용 예제
local tmp = vObject:GetComponent("TextMeshPro")

-- 기본 텍스트 설정
tmp.text = "Hello, VFramework!"
tmp.color = Color(1, 1, 1, 1)  -- 흰색


tmp:ForceMeshUpdate()
```
