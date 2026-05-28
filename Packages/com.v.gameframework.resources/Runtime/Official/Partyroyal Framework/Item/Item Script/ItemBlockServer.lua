
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local world
    local soundService

    
    local targetPosition
    local targetRotation

    local delaytime = 0
    local checkVisible = ture



    this.Item = __EX_VARIABLE__.vobject()
    this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
    this.VisibleDelay = __EX_VARIABLE__.float(0)
    this.PlaceObject = __EX_VARIABLE__.vobject()
    this.PlaceSound = __EX_VARIABLE__.asset.audioClip() -- audio clip type field


    function this.OnAwake()

        if this.Item then
            this.Item:SetWorldEnabled(this.IsVisibleOnStart)
        end
        
        checkVisible = this.IsVisibleOnStart
        
    end
    
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        world = serviceApi.world
        soundService = serviceApi.soundService
        
    end
    
    
    function this.OnUpdate(deltaTime)

        if checkVisible == true then return end

        delaytime = delaytime + deltaTime

        if delaytime >= this.VisibleDelay then
            checkVisible = true
            if this.Item then
                this.Item:SetWorldEnabled(true)
            end

        end
                
    end
    
    function this.OnDestroy()
        
    end

    __EX_FUNCTION__(this, __EX_VARIABLE__.vector3(), __EX_VARIABLE__.vector3())
    function this.SetTarget(position, rotation)

        targetPosition = position
        targetRotation = Quaternion.Euler(rotation)


        if this.Item == nil then
            return 
        end

        if this.PlaceObject == nil then
            return 
        end

        local myOwner = this.Item:GetOwnerCharacter()
        if myOwner == nil then return end
        
        local th = world:Instantiate(this.PlaceObject, targetPosition, targetRotation,1)

        if this.PlaceSound then
            soundService:Play(this.PlaceSound)
        end

    end


    __EX_FUNCTION__(this)
    function this.AppearOnEvent()

        checkVisible = true
        if this.Item then
            this.Item:SetWorldEnabled(true)
        end
    end



    __EX_FUNCTION__(this)
    function this.DisappearOnEvent()

        checkVisible = true
        if this.Item then
            this.Item:SetWorldEnabled(false)
        end
    end

