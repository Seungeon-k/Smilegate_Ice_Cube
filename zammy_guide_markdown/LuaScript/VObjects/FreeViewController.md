---
title: FreeViewController
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/FreeViewController
source_path: LuaScript/VObjects/FreeViewController.html
last_updated: "2026.04.06 오후 03:33"
---

# FreeViewController

## 모듈

> VFramework

## 개요

FreeViewController는 자유 시점 카메라 제어에 사용하는 카메라 컨트롤러 객체입니다.  

FreeViewController는 [CmeraController](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo)를 상속 받은 객체입니다.  

일반적으로 [`FindCameraController`](https://developers-zammysmith.onstove.com/ko/LuaScript/Services/CameraService/Methods/CameraService_FindCameraController_CameraServiceVo_string)로 컨트롤러를 찾은 뒤 우선순위(priority)를 조정해 활성 카메라를 전환합니다.  

카메라 전환과 입력 모드 전환이 동시에 일어나는 구간에서는 입력 잠금 상태를 함께 관리해야 시점 튐과 오입력을 줄일 수 있습니다.  

멀티플레이에서는 카메라 연출을 로컬 표현으로 다루고, 판정 동기화 로직과 분리해 구성하는 것이 안전합니다.

## 예제 코드

```lua
function this.OnStart()
    local cameraService = this.serviceApi.cameraService
    local controller = cameraService:FindCameraController("LobbyFreeCam")

    if controller ~= nil then
        controller.priority = 200
    end
end
```
