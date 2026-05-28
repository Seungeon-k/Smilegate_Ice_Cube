---
title: TopViewController
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/TopViewController
source_path: LuaScript/VObjects/TopViewController.html
last_updated: "2026.04.06 오후 03:36"
---

# TopViewController

## 모듈

> VFramework

## 개요

`TopViewController`는 [`CameraController`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo)를 상속받는 객체로,  

카메라를 캐릭터 또는 특정 대상의 상단(Top View) 시점에서 제어하는 기능을 제공합니다.  

Scene에 해당 객체가 존재할 경우, 카메라는 대상의 정상(위쪽) 에서 아래를 향해 내려다보는 시점으로 배치되고 제어됩니다.

여러 개의 TopViewController가 존재할 수 있으며, 이 경우 [`priority`](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo/Properties/CameraControllerVo_priority)  

값이 가장 높은 컨트롤러가 활성화됩니다.  

본 클래스는 [CameraController](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/CameraControllerVo)  

를 상속받아 동작합니다.
