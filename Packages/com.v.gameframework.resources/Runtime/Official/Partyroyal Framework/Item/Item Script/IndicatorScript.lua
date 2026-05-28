
    local this = __CREATOR__.new()

    ---@type VFramework.ServiceApi    
    local serviceApi
    ---@type VFramework.ScriptObject
    local scriptObject
    local playerService
    local physicService
    local inputService
    local world

    local isEquipped = false
    local isMine = false 
    local result = "None"
    
    local _checkScale
    local _prvPosition
    local _targetPosition
    local _targetRotation
    local _time = 0
    local _maxCameraYAxis = 0.98;
    
    local timeStamp
    local angleStamp
    -- local isMaxYAxis
    local swichTimeToDrag = 0.3
    local swichAngleToDrag = 2
    local indicatorTransitionSensitivity = 1
    local indicatorTransitionMax = 2.3

    local _buildDecalUpdateTime = nil
    local _buildDecalColor = nil
    

    local preHit = nil

    local targetObject
    local targetDecal
    local targetDecalMaterial
    local targetCollider 
    local targetBounds

    local floorPosition = true
    local preRotate
    local snap = true 
    local inited = false
    local _active = false

    local press = false
    local coolTime = 0




    this.Item = __EX_VARIABLE__.vobject()
    this.TargetObject = __EX_VARIABLE__.vobject()
    this.DecalObject = __EX_VARIABLE__.vobject()

    this.Scale = __EX_VARIABLE__.vector3()
    this.ActionButtonName = __EX_VARIABLE__.string()

    this.OnTargetPlacementResolved = __EX_VARIABLE__.event(__EX_VARIABLE__.vector3(), __EX_VARIABLE__.vector3())
    
    
    function this.OnStart()
    
        serviceApi = this.serviceApi
        scriptObject = this.scriptObject
        playerService = serviceApi.playerService
        physicService = serviceApi.physicsService
        inputService = serviceApi.inputService
        world = serviceApi.world

        if inputService then
            inputService.OnButtonActionEvent:AddListener(this.OnButtonEvent)
        end



        if this.Item then
            this.Item.OnEquipped:AddListener(this.OnEquipped)
            this.Item.OnUnequipped:AddListener(this.OnUnequipped)
            this.Item.OnAttackBegin:AddListener(this.OnAttackBegin)
        end

        preRotate = Quaternion.identity

        result = "None"
        inited = true
        
        
    end
    
    
    function this.OnUpdate(deltaTime)

        if coolTime > 0 then
            coolTime = coolTime - deltaTime
            if coolTime < 0 then
                coolTime = 0
            end
        end


        if this.IsValid_Update() == false then
            return 
        end

        --isMaxYAxis = false

        local targetPosProperty = this.UpdateTargetPosProperty();

        if this.IsClickState() == true then
            this.UpdateClickState()
            return
        end

        if this.IsMaxYAxis() == true then
            this.UpdateMaxYAxisState()
            return
        end

        local character = playerService.localPlayer.character
        local playerPosition = character.transform.position
        local targetPosition =  playerPosition + Vector3(0, targetPosProperty, 0)
        local ray, powerValue, dirVector = this.GetRayInfo(targetPosition)

    
        local camera = world:GetMainCamera()

        local hitInfo = this.GetHitInfo(ray, -1 )
        local position, decalPoisition, tileOffset
        local rotation = Quaternion.Euler(0, camera.transform.eulerAngles.y, 0) 
        

        if (hitInfo == nil) then --히트된 타겟이 없을 경우
            dirVector = dirVector.normalized
            position = targetPosition + (dirVector * powerValue)
            targetDecal:SetActive(false)
            _buildDecalUpdateTime = 0
            local colliders, count = this.GetOverlapCollider(position, rotation, -1)
            this.UpdateResult(position, rotation, colliders, count, -1)
        elseif snap == true then --히트된 오브젝트가 있을 경우
            position, rotation, decalPoisition, tileOffset = this.UpdateBlockSnap(hitInfo, position, rotation) --스냅을 이동시킨다.
            local colliders, count = this.GetOverlapCollider(position, rotation, -1) --빈공간 체크
            this.UpdateResult(position, rotation, colliders, count, -1)

        end

        if tileOffset then this.ActiveBuildDecal(targetDecal, decalPoisition, rotation, tileOffset) end
   
        this.UpdateItemGameObject( targetObject, position, rotation)
        this.UpdateItemGameColor()
                
    end
    
    function this.OnDestroy()



         if targetObject ~= nil then
            targetObject:Destroy() 
            targetObject = nil 
        end
         
        if targetDecal ~= nil then
            targetDecal:Destroy() 
            targetDecal = nil 
        end
        
        if inited == true then
            if inputService then
                inputService.OnButtonActionEvent:RemoveListener(this.OnButtonEvent)
            end



            if this.Item then
                this.Item.OnEquipped:RemoveListener(this.OnEquipped)
                this.Item.OnUnequipped:RemoveListener(this.OnUnequipped)
            end

        end
        
        
    end






    local function GetCameraAngles()

        local camera = world:GetMainCamera()
        if camera == nil then
            return nil
        end

        return camera.transform.eulerAngles

    end


    function this.OnEquipped(item)

        isEquipped = true
        coolTime = 0
        local myOwner = item:GetOwnerCharacter()
        if myOwner == nil then
            isMine = false
        elseif playerService.localPlayer.id == myOwner.player.id then
            isMine = true
        else
            isMine = false
        end

        if isMine == false then
            return 
        end


        -- 내 캐릭터 일때 인디케이터 생성
        if this.TargetObject ~= nil then
            targetObject = world:Instantiate(this.TargetObject, Vector3.zero, Quaternion(0,0,0,1))  
            targetObject:SetActive(false) 
        end


        if this.DecalObject ~= nil then
            targetDecal = world:Instantiate(this.DecalObject, Vector3.zero, Quaternion(0,0,0,1))  
            targetDecal:SetActive(false) 

            targetDecalMaterial = targetDecal:GetComponent("Renderer").material
            _buildDecalColor = targetDecalMaterial:GetColor("_Color")
        end

        
        
        timeStamp = Time.time 
        angleStamp = GetCameraAngles()

        
         if targetObject ~= nil then
            targetObject:SetActive(true) 

            local character = playerService.localPlayer.character
            local playerPosition = character.transform.position

            targetObject.transform.position = playerPosition
            targetObject.transform.localScale = this.Scale
            _checkScale = 1

            targetCollider = targetObject:GetComponent("Collider")
            if targetCollider ~= nil then
                targetBounds = targetCollider.bounds    
            end
            


         end

         _prvPosition = Vector3.zero
         _targetPosition = Vector3.zero
         _targetRotation = Quaternion.identity

        if targetObject ~= nil then
            targetObject:SetActive(true) 
        end
         
        if targetDecal ~= nil then
            targetDecal:SetActive(true) 
        end

        if isEquipped == false or isMine == false then
            this.SetActive(false)
            return 
        end

        if press == true then
            timeStamp = Time.time 
            angleStamp = GetCameraAngles()
            this.SetActive(true)
            return

        end

        this.SetActive(false)
    end


    function this.OnUnequipped(item)

        coolTime = 0

        if isEquipped == false then
            return 
        end

        isEquipped = false

        if isMine ==false then
            return 
        end
        isMine = false

        if targetObject ~= nil then
            targetObject:Destroy() 
            targetObject = nil 
        end
         
        if targetDecal ~= nil then
            targetDecal:Destroy() 
            targetDecal = nil
        end


        

    end

    function this.OnAttackBegin(item)

    
        if isEquipped == false or isMine == false then
            press = false
            this.SetActive(false)
            return 
        end

    

        if press == false  then
            timeStamp = Time.time 
            angleStamp = GetCameraAngles()
            this.SetActive(true)
            press = true
        end

        
        if this.IsClickState() then
            this.UpdateClickState()
        end

        

        press = false
        coolTime = this.Item.coolTime

        
        this.SetActive(false)
        this.OnTargetPlacementResolved:Call(_targetPosition, _targetRotation.ToEulerAngles)

        
    end


    function this.OnButtonEvent(actionName, buttonState)

        

        if actionName ~= this.ActionButtonName then
            return 
        end

        if buttonState ~= VFramework.ButtonState.Press then
            return
        end


        if coolTime > 0 then

            return 
        end


        if this.Item.amount <= 0 then
            return 
        end 

        

        if isEquipped == false or isMine == false then
            press = true
            return 
        end

        timeStamp = Time.time 
        angleStamp = GetCameraAngles()
        this.SetActive(true)
        press = true

            
      
    end


    function this.SetActive(active)
        if active == false then
            if targetObject ~= nil then
                targetObject:SetActive(active)
            end
             
        end
        preHit = nil 
        if targetDecal then
            targetDecal:SetActive(active)
            if active then
                _buildDecalUpdateTime = 0
            end
        end

        _active = active
        
    end


    function this.UpdateResult(position, rotation, colliders, count, layerMask)
        local buildValid = "Available"

        
        for i, v in ipairs(colliders) do
            local direction = Vector3.zero
            local distance = 0
            local collider = colliders[i]
            
           
            
            if (collider.isTrigger == false) then
                
                local penetrationResult, direction, distance = physicService:ComputePenetration(
                    targetCollider, 
                    position, 
                    rotation,
                    collider,
                    collider.transform.position,
                    collider.transform.rotation
                )
    
                if ((penetrationResult == true and 0.15 < distance)) then
                    buildValid = "Occupied"
                    break
                end
            end
            --end
        end
        
        
        if (result ~= buildValid) then 
            result = buildValid
        end
    end

    function this.GetOverlapCollider(position, rotation, layerMask)
        --Checking Empty Space
        local halfExtents = Vector3(0.5, 0.5, 0.5) * _checkScale
        
        local colliders = physicService:OverlapBox(position, halfExtents, rotation)
        local count = #colliders

        

        return colliders, count
    end

    function this.GetRayInfo(targetPosition)

        local ray, dirVector
        local powerValue = 1

        local camera = world:GetMainCamera()
       
        
        dirVector = camera.transform.forward

        local cameraPosition = camera.transform.position
        ray = Ray((targetPosition - cameraPosition).normalized, targetPosition)
        
        powerValue = 3


        return ray, powerValue, dirVector
    end


    function this.UpdateMaxYAxisState()
        local position, rotation, decalPoisition, tileOffset, hitInfo = this.UpdateMaxYAxis()  
            this.UpdateItemGameObject( targetObject, position, rotation)
            this.UpdateItemGameColor()
            this.ActiveBuildDecal(targetDecal, decalPoisition, rotation, tileOffset)
            if (hitInfo == nil) then --히트된 타겟이 없을 경우
                targetDecal:SetActive(false)
                _buildDecalUpdateTime = 0
            end
    end


    function this.ActiveBuildDecal(_buildDecal, position, rotation, tileOffset)
        _buildDecal:SetActive(true)
        indicatorTransitionSensitivity = indicatorTransitionMax
        _buildDecal.transform.position = position
        if (_buildDecal.transform.rotation ~= rotation) then
            _buildDecal.transform.rotation = rotation
            
        end

        --Easing Curve on Alpha
        _buildDecalUpdateTime = _buildDecalUpdateTime + Time.deltaTime
        _buildDecalColor.a = this.Circ_EaseOut(_buildDecalUpdateTime, 1, 0, 1)
        targetDecalMaterial:SetColor("_Color", _buildDecalColor)
        targetDecalMaterial:SetVector("_MainTex_ST", tileOffset)
    end


    function this.UpdateItemGameColor()

        local renderer = targetObject:GetComponent("Renderer")
        if renderer == nil then
            return
        end
        
        if result == "Available" then
            renderer.material:SetColor("_BaseColor", Color(0 ,0.700766802, 2.43357205, 0.517647088))
            
        else 
            renderer.material:SetColor("_BaseColor", Color(1.41421354, 0, 0, 0.788235307))
            
        end
    end


    function this.UpdateItemGameObject(itemGameObject, position, rotation)
        if (_targetPosition ~= position) then
            _prvPosition = _targetPosition
            _targetPosition = position
            _time = 0
        end
        _targetRotation = rotation
        itemGameObject.transform.rotation = rotation


        --Easing Curve on Move
        _time = _time + Time.deltaTime
        itemGameObject.transform.position = this.Expo_EaseOut(_time, 1, _prvPosition, _targetPosition)

        --Show Indicator On Raycast Valid
        if (itemGameObject.activeSelf == false) then
            _prvPosition = position
            itemGameObject.transform.position = position
            itemGameObject:SetActive(true)
        end
    end

    function this.Circ_EaseOut(elapsedTime, maxTime, startValue, endValue)
        elapsedTime = Mathf.Clamp(elapsedTime, 0, maxTime)
        
        elapsedTime = elapsedTime / maxTime - 1
        return (endValue - startValue) * Mathf.Sqrt(1 - elapsedTime * elapsedTime) + startValue
    end

    function this.Expo_EaseOut(elapsedTime, maxTime, startValue, endValue)
        elapsedTime = Mathf.Clamp(elapsedTime, 0, maxTime)

        if (elapsedTime == maxTime) then
            return endValue
        else
            return (endValue - startValue) * (-(2 ^ (-10 * elapsedTime / maxTime)) + 1) + startValue
        end
    end

    function this.IsMaxYAxis()
        local camera = world:GetMainCamera()
        local cameraTansform = camera.transform 

        return (-cameraTansform.forward.y) >= _maxCameraYAxis

    end


    function this.UpdateTargetPosProperty()
        return 1.8 
    end

    function this.IsValid_Update()
        
        if isEquipped == false or isMine == false then
            return false
        end

        if targetObject == nil then
            return false
        end

        if playerService.localPlayer.character == nil then
            return false 
        end

        if _active == false then
            return false
        end

        

        return true 

        
    end

    function this.IsClickState()
        local bTime = timeStamp + swichTimeToDrag > Time.time
        if (bTime == false) then return false end
        local anlgeDiff = (GetCameraAngles() - angleStamp).magnitude
        return anlgeDiff < swichAngleToDrag
    end

    function this.UpdateClickState()
        local position, rotation, decalPoisition, tileOffset, hitInfo = this.UpdateMaxYAxis() 
        if (_targetPosition ~= position) then
            _prvPosition = _targetPosition
            _targetPosition = position
            _time = 0
        end
        _targetRotation = rotation
    end

    function this.UpdateMaxYAxis()
        
        local character = playerService.localPlayer.character


        local playerPosition = character.transform.position
        local targetPosition = playerPosition 

        local position = targetPosition + Vector3(0, 0.5 * _checkScale, 0)
        local rotation = Quaternion.Euler(90, 0, 0)

        local ray = Ray(-Vector3.up, targetPosition + Vector3(0,2,0))
        
        local hitInfo = this.GetHitInfo(ray, -1 )
        local tileOffset = Vector4(5,5,0,0)
        local decalPoisition = position

        result = "Available"

        if ( hitInfo ) then
            position, rotation, decalPoisition, tileOffset = this.UpdateBlockSnap(hitInfo, position,rotation)
            preRotate = rotation
        end

        rotation = character.transform.rotation * Quaternion.Euler(90, 0, 0)
        position = playerPosition

        return position, rotation, decalPoisition, tileOffset , hitInfo
    end


    function this.UpdateBlockSnap(hitInfo, position, rotation)
        --TBN Not Always Accurate 
        local right
        local forward = -hitInfo.normal
        if (math.abs(Vector3.Dot(hitInfo.right, forward)) < 0.0002) then
            right = hitInfo.transform.right
        elseif (math.abs(Vector3.Dot(hitInfo.up, forward)) < 0.0002) then
            right = hitInfo.transform.up
        else
            right = hitInfo.transform.forward
        end
        local up = Vector3.Cross(forward, right)
        rotation = Quaternion.LookRotation(forward, up)

        local objectPositionToPoint = hitInfo.point - hitInfo.position
       
        --Transform to Local Space Coordinate
        local planeDistance = Vector3.Dot(objectPositionToPoint, hitInfo.normal)
        local inverseRotation = Quaternion.Inverse(hitInfo.rotation)
        local inversedNormal = inverseRotation * hitInfo.normal
        position = hitInfo.point - hitInfo.position - (hitInfo.normal * planeDistance)
        position = inverseRotation * position
        --Unify Position
        if  floorPosition == true then
            position.x = math.floor(position.x + (0.5 * _checkScale))
            position.y = math.floor(position.y + (0.5 * _checkScale))
            position.z = math.floor(position.z + (0.5 * _checkScale))
        end
        --Revert to World Space Coordinate
        local inverseNormalRate = 0.55
        
        position = position + (inversedNormal * ((0.5 * _checkScale) + 0.2))
        position = hitInfo.rotation * position
        position = position + hitInfo.position + (hitInfo.normal * planeDistance)
    
        
        local tileOffset = this.GetTileOffset(objectPositionToPoint, right, up)
        local decalPoisition = hitInfo.point
        return position, rotation, decalPoisition, tileOffset
    end

    function this.GetTileOffset(objectPositionToPoint, right, up)
        local tileOffset
       
        tileOffset = Vector4(5, 5, Vector3.Dot(objectPositionToPoint, right), Vector3.Dot(objectPositionToPoint, up))
       
        return tileOffset
    end


    function this.GetHitInfo(ray, layerMask)

        local hitCount = 0 
        local hits = physicService:RaycastAll(ray, 5)
        
        if hits ~= nil then
            hitCount = #hits    
        end
        
        local hit = this.GetMinimumHit(hits, hitCount)

    

        local hitInfo = nil
        if hit and preHit and (hit.transform == preHit.transform ) then
            hitInfo = this.HitToHitInfo(hit)
            hitInfo.position = preHit.position
            hitInfo.rotation = preHit.rotation
        elseif hit then
            hitInfo = this.HitToHitInfo(hit)
            preHit = hitInfo
        end

        return hitInfo
    end

    function  this.HitToHitInfo(hit)
        if hit == nil then return nil end
        local hitInfo = {}
        hitInfo.transform = hit.transform
        hitInfo.normal = hit.normal
        hitInfo.right = hit.transform.right
        hitInfo.up = hit.transform.up
        hitInfo.point = hit.point
        hitInfo.position = hit.transform.position
        hitInfo.rotation = hit.transform.rotation
        return hitInfo

    end

    function this.GetMinimumHit(hits, length)
        local hit
        local minDistance = 999999

        for i, v in ipairs(hits) do
            
            if (v.collider.isTrigger == false) then
                local character = v.collider.vObject:Cast("Character")
                if character == nil and v.distance < minDistance then
                    minDistance = v.distance
                    hit = v
                end
               
            end

        end

        return hit
    end





