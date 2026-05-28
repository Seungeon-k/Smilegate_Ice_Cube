---
title: OnChangedLife
source_url: https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo/Events/Player_OnChangedLife
source_path: LuaScript/VObjects/PlayerVo/Events/Player_OnChangedLife.html
last_updated: "2026.04.06 오후 03:36"
---

# OnChangedLife

## 객체

> [Player](https://developers-zammysmith.onstove.com/ko/LuaScript/VObjects/PlayerVo)

## 설명

`OnChangedLife`는 플레이어의 `life` 값이 변경될 때 호출되는 이벤트입니다.  

피격, 낙하, 회복 효과, 라운드 규칙에 따른 생명 보정처럼 생명 수를 변경하는 흐름에서 발생합니다.  

생명 수 감소 직후 캐릭터 제거/리스폰 이벤트가 이어질 수 있으므로, 핸들러에서는 대상 유효성을 먼저 점검한 뒤 후속 처리를 실행하는 것이 안전합니다.

## 프로퍼티 정의

- **이름**: `OnChangedLife`
- **타입**: [`PlayerEvent`](https://developers-zammysmith.onstove.com/ko/LuaScript/Events/PlayerEvent)
- **읽기 가능(Read)**: ✅
- **쓰기 가능(Write)**: ❌

### 매개변수

| **형식** | **파라미터** | **설명** |
| --- | --- | --- |
| `Player` | `player` | 생명 수가 변경된 플레이어 객체입니다. 최신 값은 `player.life`에서 확인합니다. |

## 사용 예제

```lua
function this.OnStart()
    local playerService = this.serviceApi.playerService
    local localPlayer = playerService.localPlayer

    if localPlayer ~= nil then
        localPlayer.OnChangedLife:AddListener(this.OnChangedLifeHandler)
    end
end

function this.OnChangedLifeHandler(player)
    if player == nil then
        return
    end

    this.scriptObject:Log("life changed: " .. tostring(player.life))
    this.RefreshLifeUI(player.life)
end
```

## 참고 사항

`OnChangedLife`와 캐릭터 생성/제거 이벤트가 같은 프레임에 연달아 호출될 수 있으므로, 이벤트 간 처리 순서를 고정해 두는 것이 좋습니다.
