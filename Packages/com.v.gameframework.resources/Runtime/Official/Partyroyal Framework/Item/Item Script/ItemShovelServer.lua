
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local playerService
    local physicService
    local soundService

    local list = {}
    local set = {} 

    local delaytime = 0
    local checkVisible = ture

    this.item = __EX_VARIABLE__.vobject()
    this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
    this.VisibleDelay = __EX_VARIABLE__.float(0)
    this.SwingRange = __EX_VARIABLE__.float(3)
    this.Power = __EX_VARIABLE__.float(40)
    this.PowerMaxSpeed = __EX_VARIABLE__.float(0)
    this.HitSounds = __EX_VARIABLE__.list(__EX_VARIABLE__.asset.audioClip())


    function this.OnAwake()

    
        if this.item then
            this.item:SetWorldEnabled(this.IsVisibleOnStart)
        end
        
        checkVisible = this.IsVisibleOnStart
        
    end
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject

        playerService = serviceApi.playerService
        physicService = serviceApi.physicsService
        soundService = serviceApi.soundService

        if this.item then
            this.item.OnAttack:AddListener(this.OnAttack)
            this.item.OnAttackBegin:AddListener(this.OnAttackBegin)
        end
        
    end
    
    
    function this.OnUpdate(deltaTime)

        if checkVisible == true then return end

        delaytime = delaytime + deltaTime

        if delaytime >= this.VisibleDelay then
            checkVisible = true
            if this.item then
                this.item:SetWorldEnabled(true)
            end

        end
                
    end
    



    local function add(obj)
        if set[obj] then return false end -- 이미 있으면 중복 추가 방지
        table.insert(list, obj)
        set[obj] = true
        return true
    end

    local function contains(obj)
        return set[obj] == true
    end

    function this.OnAttackBegin(item)
        list = {}
        set  = {}  
    end


    local function AngleAtA_Deg(a, b, c)
        local ab = b - a
        local ac = c - a

        -- 길이가 0에 가까우면 각도 정의 불가 (Vector3.Angle 내부 Normalize는 0벡터면 90도가 나올 수 있어서 방어)
        if ab:SqrMagnitude() < 1e-10 or ac:SqrMagnitude() < 1e-10 then
            return nil
        end

        return Vector3.Angle(ab, ac) -- degrees (0~180)
    end

    local function PlayHitSound()
        if not this.HitSounds then return  end

        local count = #this.HitSounds

        if count == 0 then return end

        local idx = math.random(1, count)

        if this.HitSounds[idx] == nil then return end

        soundService:Play(this.HitSounds[idx])



    end

    function this.OnAttack(item)

        local itemPosition = item.transform.position 

        local colliders = physicService:OverlapSphere(itemPosition, this.SwingRange)

        local myOwner = item:GetOwnerCharacter()

        for i = 1, #colliders do
            local v = colliders[i]
            local go = v.vObject

            

            if myOwner ~= go then

                local angle = AngleAtA_Deg(myOwner.transform.position, go.transform.position, item.transform.position)

                 
                if angle <= 55 then
                    local character = go:Cast("Character") 
                    if not character then
                        -- 캐릭터가  아니면 Add Force 를 하자. 
                        
                        if v.attachedRigidbody then
                            if contains(go) == false then
                                local to = v.attachedRigidbody.transform.position + Vector3(0, 1, 0)
                                local direct = to - item.transform.position
                                local f = direct.normalized * this.Power

                                v.attachedRigidbody:AddForce(f, VFramework.ForceMode.Impulse)
                                PlayHitSound()
                                add(go)
                            end

                        end

                    else
                        -- 캐릭터이면 Knockback 를 하고

                        if contains(go) == false then


                            local to = v.attachedRigidbody.transform.position + Vector3(0, 1, 0)
                            local direct = to - item.transform.position
                            local f = direct.normalized * this.Power

                            character:KnockBack(f,  VFramework.ForceMode.Impulse, this.PowerMaxSpeed)
                            PlayHitSound()
                            add(go)
                        end

                    end
                end

            end

        end
    end



    __EX_FUNCTION__(this)
    function this.AppearOnEvent()

        checkVisible = true
        if this.item then
            this.item:SetWorldEnabled(true)
        end
    end



    __EX_FUNCTION__(this)
    function this.DisappearOnEvent()

        checkVisible = true
        if this.item then
            this.item:SetWorldEnabled(false)
        end
    end

