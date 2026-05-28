
    local this = __CREATOR__.new()
        
    local serviceApi
    local scriptObject
    local myItem

    local equipModel
    local activeListen = false

    local delaytime = 0
    local checkVisible = ture
    local myBuff

    this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
    this.VisibleDelay = __EX_VARIABLE__.float(0)
    this.Buff = __EX_VARIABLE__.vobject()
    this.EquipModel = __EX_VARIABLE__.vobject()
    

    function this.OnAwake()

        scriptObject = this.scriptObject
        myItem = scriptObject.parent

        if myItem then
            myItem:SetWorldEnabled(this.IsVisibleOnStart)
        end
        
        checkVisible = this.IsVisibleOnStart
        
    end

    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject

        myItem = scriptObject.parent

        if myItem then
            if myItem.OnAttackBegin then
                myItem.OnAttackBegin:AddListener(this.OnAttackBegin)
            end
            
        end

        


        
    end
    
    
    function this.OnUpdate(deltaTime)
 
        if checkVisible == true then return end

        delaytime = delaytime + deltaTime

        if delaytime >= this.VisibleDelay then
            checkVisible = true
            if myItem then
                myItem:SetWorldEnabled(true)
            end

        end

    end


    local function RemoveListeners(itemBuff)

        if itemBuff then
            itemBuff.OnRemoved:RemoveListener(this.OnRemoved)
            itemBuff.OnFreezed:RemoveListener(this.OnFreezed)
            itemBuff.OnResumed:RemoveListener(this.OnResumed)
            activeListen = true
        end
        
    end

    

    local function AddListeners(itemBuff)

        if itemBuff then
            itemBuff.OnRemoved:AddListener(this.OnRemoved)
            itemBuff.OnFreezed:AddListener(this.OnFreezed)
            itemBuff.OnResumed:AddListener(this.OnResumed)
            activeListen = true
        end
        
    end

    function this.OnDestroy()

        -- 버프가 진행 중이면 RemoveLisnter 처리 
        if activeListen and myBuff then
            RemoveListeners(myBuff)
        end
        
    end

    function this.OnAttackBegin(item)
        
        scriptObject:Log("OnAttackBegin")

        local myOwner = item:GetOwnerCharacter()

        -- add buff
        this.EquipModel:SetActive(false)
        myBuff = myOwner:AddBuff(this.Buff)

        if myBuff then
            AddListeners(myBuff)
        end

    end


    __EX_FUNCTION__(this)
    function this.AppearOnEvent()

        checkVisible = true
        if myItem then
            myItem:SetWorldEnabled(true)
        end
    end



    __EX_FUNCTION__(this)
    function this.DisappearOnEvent()

        checkVisible = true
        if myItem then
            myItem:SetWorldEnabled(false)
        end
    end
    

    ----------------------------------------------------------------
    -- Buff Event
    ----------------------------------------------------------------

    function this.OnRemoved(character, buff)
        if myBuff == buff then
            this.EquipModel:SetActive(true)
            RemoveListeners(buff)    
            myBuff = nil 
        end
        
    end


    function this.OnFreezed(character, buff)
        if myBuff == buff then
            this.EquipModel:SetActive(true)
            RemoveListeners(buff)
        end
        
    end

    function this.OnResumed(character, buff)
        if myBuff == buff then
            this.equipModel:SetActive(false)
            AddListeners(buff)
        end
        
    end