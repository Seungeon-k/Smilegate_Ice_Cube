local this = __CREATOR__.new()

local serviceApi
local script

-- ✅ 노출 변수
this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)     -- 시작할 때 보이기
this.IsAutoStart = __EX_VARIABLE__.bool(true)          -- 자동 발사 시작
this.AutoStartDelay = __EX_VARIABLE__.float(1.0)       -- 자동 시작 딜레이

this.OnShow = __EX_VARIABLE__.event()        -- 보이기
this.OnHide = __EX_VARIABLE__.event()        -- 숨기기

this.OnaStart = __EX_VARIABLE__.event()        -- 활성화

-- 내부 상태
local autoStartTimer = 0
local isAutoStartPending = false
local fireIntervalTimer = 0
local isFiringRepeatedly = false
local isVisible = true

----------------------------------------------------------
-- 표시 관련 함수
----------------------------------------------------------

-- ✅ 보이기
__EX_FUNCTION__(this)
function this:Show()
    if this.VisibleRoot ~= nil then
        this.VisibleRoot:SetActive(true)
        isVisible = true
        script:Log("VisibleRoot set Active = true")
    end
end

-- ✅ 숨기기
__EX_FUNCTION__(this)
function this:Hide()
    if this.VisibleRoot ~= nil then
        this.VisibleRoot:SetActive(false)
        isVisible = false
        script:Log("VisibleRoot set Active = false")
    end
end

-- ✅ 시작 시 표시 설정
function this:ApplyInitialVisibility()
    if this.IsVisibleOnStart then
        this:Show()
    else
        this:Hide()
    end
end
