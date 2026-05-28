
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local inputService
    local uiService 
    local world


    local active = false
    local prewarmCount = 10
    local duration = 0.35

    local root
    local canvas 
    

    this.isShowOnStart = __EX_VARIABLE__.bool(false)
    this.touchVfxPrefab = __EX_VARIABLE__.vobject()


    this._pool = {}
    this._active = {}

    -- 간단 queue
    local function q_push(q, v) q[#q + 1] = v end
    local function q_pop(q)
        if #q == 0 then return nil end
        local v = q[1]
        table.remove(q, 1)
        return v
    end
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject

        inputService = serviceApi.inputService
        uiService = serviceApi.uiService
        


        inputService.OnActionPositionEvent:AddListener(this.OnActionPositionEvent)

        root = scriptObject.parent
        active = this.isShowOnStart
        canvas = uiService.canvas
        

        this._pool = {}
        this._active = {}


        this.Prewarm()
        
    end

    function this.OnUpdate(deltaTime)

        --  이펙트 시간 감소 후 반환
        local dt = deltaTime
        for i = #this._active, 1, -1 do
            local item = this._active[i]
            item.t = item.t - dt
            if item.t <= 0 then
                this.ReleaseToPool(item.rt)
                table.remove(this._active, i)
            end
        end

    end
    
    function this.Prewarm()
        if this.touchVfxPrefab == nil or root == nil then return end 

        for i = 1, (prewarmCount or 0) do
             local inst  = uiService:Instantiate(this.touchVfxPrefab)
             inst:SetParent(root)
             inst:SetActive(false)
             q_push(this._pool, inst)

        end
        
    end


    function this.OnActionPositionEvent(actionName, buttonState, point, id)

        if active == false then
            return
        end

        if buttonState ~= VFramework.ButtonState.Press then
            return 
        end

        this.SpawnAtScreenPosition(point)


    end

    function this.GetFromPool()
        local inst = q_pop(this._pool)
        if inst ~= nil then return inst end

        -- 풀 부족하면 추가 생성
        local newInst = uiService:Instantiate(this.touchVfxPrefab)
        newInst:SetParent(root)
        newInst:SetActive(false)
        return newInst
    end


    function this.ReleaseToPool(rt)
        if rt == nil then return end
        rt:SetActive(false)
        rt:SetParent(root)
        q_push(this._pool, rt)
    end


    local function ScreenToAnchored_ByCamera(screenPos, parent)
        -- 1) Screen -> World (캔버스 평면 위)
        local worldPos = uiService:ScreenToWorldPoint(Vector3(screenPos.x, screenPos.y, canvas.planeDistance))

        -- 2) World -> parent local
        local local3 = parent:InverseTransformPoint(worldPos)

        -- 3) anchoredPosition에 들어갈 (x,y)
        return Vector2(local3.x, local3.y)
    end

    function this.SpawnAtScreenPosition(screenPos)

        if canvas == nil or root == nil or this.touchVfxPrefab == nil then
            return
        end


        local effect = this.GetFromPool()
        effect:SetParent(root)
        effect:SetActive(true)

        local anchored = ScreenToAnchored_ByCamera(screenPos,  root.transform)

        
        effect.transform.anchoredPosition = anchored
        effect.transform.localScale = Vector3(5, 5, 5)
        this._active[#this._active + 1] = { rt = effect, t = duration }

    end


    __EX_FUNCTION__(this)
    function this.EnableEffect()

        active = true
      
    end

    __EX_FUNCTION__(this)
    function this.DisableEffect()

        active = false
      
    end



