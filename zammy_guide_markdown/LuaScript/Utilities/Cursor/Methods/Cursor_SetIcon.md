---
title: SetIcon
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/Utilities/Cursor/Methods/Cursor_SetIcon
source_path: LuaScript/Utilities/Cursor/Methods/Cursor_SetIcon.html
last_updated: "2026.04.06 오후 03:30"
---

# SetIcon

## 객체

> Cursor

## 설명

`SetIcon`은 커서 아이콘 텍스처와 핫스팟 위치를 설정합니다.

기본 호출은 `texture`와 `hotspot`을 전달해 커서 이미지를 바꾸는 방식입니다.  

`mode`를 함께 전달하면 커서 아이콘 적용 방식을 함께 지정할 수 있습니다.

## 함수

SetIcon(texture, hotspot)  
  

SetIcon(texture, hotspot, mode)

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| [`Texture2D`](https://developers-zammysmith.onstove.com/ko/LuaScript/Resources/Texture2D) | `texture` | 커서 아이콘으로 사용할 텍스처입니다. |
| [`Vector2`](https://developers-zammysmith.onstove.com/ko/LuaScript/DataTypes/Vector2) | `hotspot` | 커서 클릭 기준점이 되는 핫스팟 좌표입니다. |
| `CursorMode` | `mode` | 커서 아이콘 적용 방식을 지정하는 선택 매개변수입니다. 생략하면 기본 모드가 사용됩니다. |

### 반환값

없음

## 예제 코드

```lua
function this.OnStart()
    local inputService = this.serviceApi.inputService
    local cursor = inputService.cursor
    local iconTexture = this.scriptObject.iconTexture

    cursor:SetIcon(iconTexture, Vector2(16, 16))
end
```
