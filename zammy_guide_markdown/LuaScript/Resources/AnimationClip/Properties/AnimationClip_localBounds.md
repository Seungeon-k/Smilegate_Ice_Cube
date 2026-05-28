---
title: localBounds
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip/Properties/AnimationClip_localBounds
source_path: LuaScript/Resources/AnimationClip/Properties/AnimationClip_localBounds.html
last_updated: "2026.04.06 오후 03:21"
---

# localBounds

## 객체

> [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)

## 설명

localBounds는 [AnimationClip](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/AnimationClip)이 재생되는 동안 오브젝트가 로컬 좌표계(Local Space) 에서 차지하게 되는 경계 영역(Bounding Box) 을 나타내는 속성입니다.  

이는 애니메이션 전체를 통해 계산된 최소/최대 좌표값을 기준으로 생성된 바운딩 볼륨으로, 씬 뷰와 카메라 클리핑, 콜라이더 동작 등에 중요한 역할을 합니다.

예를 들어, 점프 애니메이션을 재생할 때 캐릭터가 위로 솟아오른다면, localBounds는 그 위치까지 포함하는 범위를 반환합니다.

## 프로퍼티 정의

- **이름**: `localBounds`
- **타입**: [`Bounds`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Bounds)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

## 사용 예제

```lua
local clip = someAnimationClip

-- localBounds 출력
local bounds = clip.localBounds
print("Center: " .. tostring(bounds.center))
print("Size: " .. tostring(bounds.size))

-- 특정 로직에 활용 (예: 카메라 거리 조정)
local halfHeight = bounds.extents.y
print("바운드 절반 높이: " .. halfHeight)
```

## 참고 사항

localBounds는 애니메이션의 모든 키프레임을 분석하여 계산된 전체 범위를 반환합니다.
