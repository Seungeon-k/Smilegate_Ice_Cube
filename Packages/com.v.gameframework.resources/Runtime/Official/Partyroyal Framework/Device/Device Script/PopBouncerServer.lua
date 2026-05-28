
local this = __CREATOR__.new()

local serviceApi
local script
local world
local colliders = {}

this.RootObj = __EX_VARIABLE__.vobject()
this.LifeTime = __EX_VARIABLE__.float(3.0)
this.KnockbackScript = __EX_VARIABLE__.vobject()
this.NotiDestroyEvent = __EX_VARIABLE__.event(__EX_VARIABLE__.vobject())

local knockbackScript = nil
local lifeTimer = 0
local destroyTimer = 0
-- 클라이언트에서 파괴를 위한 event동작을 고려한 delay
local DestroyDuration = 5.0
local isDestroying = false

function this.OnStart()

    serviceApi = this.serviceApi
    script = this.scriptObject
    world = serviceApi.world
    lifeTimer = this.LifeTime
    colliders = script.parent:GetComponentsInChildren("Collider")

    if this.RootObj == nil then
        script:Log("[PopBouncer] destroy root is nil")
    end    

    knockbackScript = this.KnockbackScript:GetLua()
    if knockbackScript == nil then
        script:Log("[PopBouncer] knockback script is nil ")
    else
        knockbackScript:ChangeDisableInternalMode()
    end
end

function this.OnUpdate(deltaTime)

    if isDestroying then
        destroyTimer = destroyTimer - deltaTime
        if destroyTimer <= 0 then            
            this.RootObj:Destroy()
        end
        return
    end

    lifeTimer = lifeTimer - deltaTime
    if lifeTimer <= 0 then
        this.Deactive()
        this.DestroySelf()
        if this.NotiDestroyEvent ~= nil then
            this.NotiDestroyEvent:Call(nil)
        end        
    end

end


function this.DestroySelf()

    if isDestroying then return end
    isDestroying = true
    destroyTimer = DestroyDuration
    
end


__EX_FUNCTION__(this)
function this.Active()

    if colliders == nil then return end
    for i = 1, #colliders do
        if colliders[i] ~= nil then
            colliders[i].enabled = true
        end
    end
end


__EX_FUNCTION__(this)
function this.Deactive()

    if colliders == nil then return end
    for i = 1, #colliders do
        if colliders[i] ~= nil then
            colliders[i].enabled = false
        end
    end
end

function this.OnCollisionEnter(collision)       
    if script == nil then return end    

    if isDestroying then 
        script:Log("[collide] PopBouncer is destroying")
        return 
    end

    --if this.KnockbackScript == nil then return end;

    if collision == nil then 
        script:Log("[collide] collision is null")
        return 
    end

    local obj = collision.vObject
    if obj == nil then         
        return 
    end

    local character = obj:Cast("Character")
    if character == nil then         
        return 
    end  

    this.Deactive();
    this.DestroySelf()

    if knockbackScript ~= nil then
        knockbackScript.KnockbackAround(character)
    end    

    if this.NotiDestroyEvent ~= nil then
        this.NotiDestroyEvent:Call(character)
    end
end
