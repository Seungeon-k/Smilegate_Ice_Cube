local this = __CREATOR__.new()

local serviceApi
local script

-- 노출 변수
this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
this.DissolveSpeed = __EX_VARIABLE__.float(2.0)

-- 내부 상태
local renderers = {}
local visibleStageRoot = nil
local walrusRoot = nil        -- 추가
local root = nil
local animator = nil

local dissolveValue = 1.0
local dissolveTarget = 1.0
local isDissolving = false
local hidePending = false
local isVisible = true

----------------------------------------------------------
-- Renderer Dissolve 적용
----------------------------------------------------------
local function ApplyDissolve(value)
    for i = 1, #renderers do
        local r = renderers[i]
        if r ~= nil and r.material ~= nil then
            r.material:SetFloat("_Dissolve", value)
        end
    end
end

----------------------------------------------------------
-- Show / Hide
----------------------------------------------------------
__EX_FUNCTION__(this)
function this:Show()
    if visibleStageRoot == nil then return end

    -- Stage는 보이기 시작
    visibleStageRoot:SetActive(true)
    isVisible = true
    hidePending = false

    -- Walrus는 Stage가 완전히 보일 때까지 비활성
    if walrusRoot ~= nil then
        walrusRoot:SetActive(false)
    end

    dissolveTarget = 0.0
    isDissolving = true
end

__EX_FUNCTION__(this)
function this:Hide()
    if visibleStageRoot == nil then return end

    dissolveTarget = 1.0
    isDissolving = true
    hidePending = true

    -- Hide 할 때 Walrus도 비활성
    if walrusRoot ~= nil then
        walrusRoot:SetActive(false)
    end
end

----------------------------------------------------------
-- OnStart
----------------------------------------------------------
function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject

    root = script.parent
    animator = root:GetComponent("Animator")

    -- Stage root
    visibleStageRoot = root:Find("Dummy_Party_Cannon_Platform")

    -- Walrus root
    walrusRoot = root:Find("Party_Walrus_Master")

    if walrusRoot ~= nil then
        walrusRoot:SetActive(false)   -- 초기엔 반드시 꺼야 함
    end

    -- Renderer 수집
    if visibleStageRoot ~= nil then
        local comps = visibleStageRoot:GetComponentsInChildren("Renderer")
        for i = 1, #comps do
            renderers[#renderers + 1] = comps[i]
        end
    end

    -- 초기 Dissolve = 1 (완전 감춤)
    dissolveValue = 1.0
    ApplyDissolve(1.0)

    if this.IsVisibleOnStart then
        visibleStageRoot:SetActive(true)
        this:Show()   -- 1 → 0 애니메이션 시작
    else
        visibleStageRoot:SetActive(false)
    end
end

----------------------------------------------------------
-- OnUpdate
----------------------------------------------------------
function this.OnUpdate(dt)
    if isDissolving then
        local diff = dissolveTarget - dissolveValue
        local step = this.DissolveSpeed * dt

        if math.abs(diff) <= step then
            dissolveValue = dissolveTarget
            isDissolving = false

            ApplyDissolve(dissolveValue)

            -- 완전 사라짐 → Stage off
            if hidePending and visibleStageRoot ~= nil then
                visibleStageRoot:SetActive(false)
                hidePending = false
                isVisible = false
                return
            end

            -- 완전 표시된 시점 = dissolveValue == 0
            if dissolveValue == 0 then
                -- Walrus 활성
                if walrusRoot ~= nil then
                    walrusRoot:SetActive(true)
                end

                -- Animator Trigger("Spawn")
                if animator ~= nil then
                    animator:SetTrigger("Spawn")
                end
            end
        else
            dissolveValue = dissolveValue + (diff > 0 and step or -step)
            ApplyDissolve(dissolveValue)
        end
    end
end
