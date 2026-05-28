---
title: MeshRenderer
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/MeshRenderer
source_path: LuaScript/Components/MeshRenderer.html
last_updated: "2026.04.06 오후 02:53"
---

# MeshRenderer

## 모듈

> VFramework

## 개요

MeshRenderer는 3D 모델의 시각적 표현을 담당하는 컴포넌트입니다.  

MeshFilter가 보유한 메쉬 데이터를 렌더링하여 화면에 표시하며, 재질(Material)을 통해 색상, 질감, 반사광 등의 시각 효과를 정의합니다.  

주로 오브젝트의 외형을 표현하고, 광원과 쉐이더에 의해 최종적으로 화면에 렌더링됩니다.

## 속성

| 이름 | 타입 | 설명 | 읽기 | 쓰기 |
| --- | --- | --- | --- | --- |
| *(없음)* |  | `MeshRenderer`는 기본적으로 렌더링 속성과 머티리얼 관련 속성을 상속받아 사용합니다. |  |  |

## 메서드

| 메서드명 | 설명 | 반환값 |
| --- | --- | --- |
| *(없음)* | `MeshRenderer`는 주로 속성 기반으로 제어되며, 직접 호출되는 메서드는 없습니다. | - |

## 예제 코드

```lua
-- MeshRenderer 사용 예제
local meshRenderer = vObject:GetComponent("MeshRenderer")

-- 재질(Material) 설정
meshRenderer.material = customMaterial

-- 여러 재질 적용 (예: 복합 오브젝트)
meshRenderer.materials = customMaterials

-- 렌더러 활성/비활성
meshRenderer.enabled = true

-- 오브젝트 색상 변경 (머티리얼의 컬러 프로퍼티 제어)
meshRenderer.material.color = Color(0.2, 0.8, 1.0, 1.0)
```
