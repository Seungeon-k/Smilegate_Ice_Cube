
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject

    local myItem
    local activeListen = false
    local delaytime = 0
    local checkVisible = ture


    this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
    this.VisibleDelay = __EX_VARIABLE__.float(0)
    this.ActionBuff = __EX_VARIABLE__.vobject()


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
                activeListen = true
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



    function this.OnAttackBegin(item)
        
        local myOwner = item:GetOwnerCharacter()

        -- add buff
        if this.ActionBuff then
            local myBuff = myOwner:AddBuff(this.ActionBuff)    
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


