---
title: alphaHitTestMinimumThreshold
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image/Properties/Image_alphaHitTestMinimumThreshold
source_path: LuaScript/Components/Image/Properties/Image_alphaHitTestMinimumThreshold.html
last_updated: "2026.04.06 오후 02:52"
---

# alphaHitTestMinimumThreshold

## 객체

> [Image](https://developers-zammysmith.onstove.com/ko/LuaScript/Components/Image)

## 설명

이 프로퍼티는 이미지의 알파 히트 테스트 최소 임계값을 설정하거나 가져오는 데 사용됩니다. 이 값은 이미지의 투명한 부분이 클릭 가능한 영역으로 간주되는지를 결정합니다.

값은 0에서 1 사이의 실수로 설정할 수 있으며, 0은 완전히 투명한 부분을 의미하고 1은 완전히 불투명한 부분을 의미합니다. 이 프로퍼티를 설정할 때는 이미지의 시각적 효과에 영향을 줄 수 있으므로 주의해야 합니다.

## 프로퍼티 정의

- **이름**: `alphaHitTestMinimumThreshold`
- **타입**: `number`
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ✅

## 사용 예제

```lua
image.alphaHitTestMinimumThreshold
```

## 참고 사항

동기화 미지원
