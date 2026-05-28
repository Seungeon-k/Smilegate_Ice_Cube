---
title: MeshCollider
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/MeshCollider
source_path: LuaScript/Components/MeshCollider.html
last_updated: "2026.04.06 오후 02:53"
---

# MeshCollider

## 모듈

> VFramework

## 개요

MeshCollider는 메쉬(Polygon Mesh)의 형태를 그대로 충돌 영역으로 사용하는 콜라이더입니다.  

정확한 충돌 감지가 필요할 때 사용되며, 복잡한 오브젝트 형태에 맞는 정밀한 물리 충돌 처리를 제공합니다.  

단, 계산 비용이 높기 때문에 실시간 물리 연산보다는 고정된 지형이나 구조물에 주로 사용됩니다.

## 속성

| 이름 | 타입 | 설명 | 읽기 | 쓰기 |
| --- | --- | --- | --- | --- |
| *(없음)* |  | `MeshCollider`는 주로 부모 클래스인 `Collider`의 공통 속성(`enabled`, `isTrigger`, `material` 등)을 사용합니다. |  |  |

## 메서드

| 메서드명 | 설명 | 반환값 |
| --- | --- | --- |
| *(없음)* | `MeshCollider`는 주로 설정 중심으로 사용되며, 별도의 메서드는 제공하지 않습니다. | - |

## 예제 코드

```lua
-- MeshCollider 사용 예제
local meshCollider = vObject:AddComponent("MeshCollider")

-- 메쉬 리소스 로드 및 할당
meshCollider.sharedMesh = newLoadedMesh

-- 트리거 설정 (충돌 대신 감지용으로 사용)
meshCollider.isTrigger = false

-- 물리 재질 적용
local mat = PhysicMaterial()
mat.bounciness = 0.1
mat.dynamicFriction = 0.5
meshCollider.material = mat

-- 콜라이더 활성화 상태 확인
if meshCollider.enabled then
    print("MeshCollider가 활성화되어 있습니다.")
end
```
