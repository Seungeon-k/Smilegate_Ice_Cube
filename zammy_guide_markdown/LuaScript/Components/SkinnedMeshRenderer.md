---
title: SkinnedMeshRenderer
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/SkinnedMeshRenderer
source_path: LuaScript/Components/SkinnedMeshRenderer.html
last_updated: "2026.04.06 오후 02:55"
---

# SkinnedMeshRenderer

## 모듈

> VFramework

## 개요

SkinnedMeshRenderer는 Bone 애니메이션을 지원하는 3D 모델을 렌더링하기 위한 컴포넌트입니다.  

주로 캐릭터, 몬스터, 의상 등 뼈대 기반 애니메이션이 적용된 메쉬를 표현할 때 사용됩니다.  

본의 움직임에 따라 메쉬가 자동으로 변형(Skinning)되며, 머티리얼, 조명, 그림자 등의 일반 렌더링 속성도 함께 제어할 수 있습니다.

## 속성

| 이름 | 타입 | 설명 | 읽기 | 쓰기 |
| --- | --- | --- | --- | --- |
| *(없음)* |  | `SkinnedMeshRenderer`는 기본적으로 `Renderer`의 모든 속성을 상속받으며, 추가로 본(bone) 및 스킨(mesh) 관련 속성을 제공합니다. |  |  |

## 메서드

| 메서드명 | 설명 | 반환값 |
| --- | --- | --- |
| *(없음)* | `SkinnedMeshRenderer`는 주로 애니메이션 시스템과 함께 동작하며, 직접 호출되는 메서드는 제공되지 않습니다. | - |

## 예제 코드

```lua
-- SkinnedMeshRenderer 사용 예제
local skinnedMeshRenderer = vObject:GetComponent("SkinnedMeshRenderer")

-- 현재 사용 중인 메쉬 확인
local mesh = skinnedMeshRenderer.sharedMesh
print("Mesh 이름:", mesh.name)

-- 머티리얼 변경
skinnedMeshRenderer.material = newLoadedMaterial

-- 본 정보 출력
for i, bone in ipairs(skinnedMeshRenderer.bones) do
    print("Bone[" .. i .. "]:", bone.name)
end

-- 루트 본 설정
skinnedMeshRenderer.rootBone = vObject.transform

-- 렌더러 제어
skinnedMeshRenderer.enabled = true
skinnedMeshRenderer.receiveShadows = true
```
