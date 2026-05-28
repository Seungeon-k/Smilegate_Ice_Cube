local this = __CREATOR__.new()

local serviceApi
local script

-- ✅ 노출 변수
this.DisplayNumber = __EX_VARIABLE__.int(1)                 -- 표시할 숫자 (1~14)
this.UseRandomNumber = __EX_VARIABLE__.bool(false)          -- 랜덤 숫자 표시 여부
this.LifeTime = __EX_VARIABLE__.float(10.0)                 -- 존재 시간 (초)

this.BallMesh = __EX_VARIABLE__.vobject()           -- 당구공 Mesh 오브젝트
this.NumberTextures = __EX_VARIABLE__.list('texture')       -- 숫자별 텍스처 리스트 (_BaseMap 교체용)

local Rigidbody 

-- 내부 상태
local lifeTimer = 0

----------------------------------------------------------
-- 초기화
----------------------------------------------------------
function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject
    
    Rigidbody = script.parent:GetComponent("Rigidbody")
    Rigidbody.useGravity = false
    
    lifeTimer = this.LifeTime

    -- ✅ 번호 선택
    local texIndex
    if this.UseRandomNumber then
        texIndex = math.random(1, #this.NumberTextures)
        this.DisplayNumber = texIndex
    else
        texIndex = math.min(math.max(this.DisplayNumber, 1), #this.NumberTextures)
    end

    -- ✅ 텍스처 교체 (BaseMap 고정)
    if this.BallMesh ~= nil then
        local mesh = this.BallMesh:GetComponent("MeshRenderer")
        if mesh ~= nil and #this.NumberTextures > 0 then
            local tex = this.NumberTextures[texIndex]
            if tex ~= nil then
                local mat = mesh.material
                mat:SetTexture("_BaseMap", tex)
                script:Log("Applied _BaseMap texture for number " .. tostring(this.DisplayNumber))
            else
                script:Log("Texture for number " .. tostring(texIndex) .. " is nil")
            end
        else
            script:Log("No MeshRenderer or texture list empty")
        end
    else
        script:Log("No BallMesh assigned")
    end

    script:Log("BilliardBall ready (Number " .. tostring(this.DisplayNumber) .. ")")
end

----------------------------------------------------------
-- 매 프레임 처리
----------------------------------------------------------
function this.OnUpdate(deltaTime)
    lifeTimer = lifeTimer - deltaTime
    if lifeTimer <= 0 then
        this:DestroySelf()
    end
end
----------------------------------------------------------
-- 제거 함수
----------------------------------------------------------
function this:DestroySelf()
    script:Log("BilliardBall destroyed (LifeTime expired)")
    script.parent:Destroy()
end
