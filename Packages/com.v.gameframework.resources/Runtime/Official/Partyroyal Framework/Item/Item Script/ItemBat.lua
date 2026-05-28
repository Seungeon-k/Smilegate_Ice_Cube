

local this = __CREATOR__.new()

local serviceApi
local script

local playerService
local physicService
local soundService

local delaytime = 0
local checkVisible = ture



local list = {}
local set = {}  


this.item = __EX_VARIABLE__.vobject()
this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
this.VisibleDelay = __EX_VARIABLE__.float(0)
this.power = __EX_VARIABLE__.float(5)
this.powerMaxSpeed = __EX_VARIABLE__.float(0)
this.hitSound = __EX_VARIABLE__.asset.audioClip()


function this.OnAwake()

    if this.item then
        this.item:SetWorldEnabled(this.IsVisibleOnStart)
    end
    
    checkVisible = this.IsVisibleOnStart
    
end


function this.OnStart()    
    serviceApi = this.serviceApi        
    script = this.scriptObject   
    

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


function this.OnAttack(item)

    local size = Vector3(1, 5, 2)
    size = size / 2

    local colliders = physicService:OverlapBox(item.transform.position, size, item.transform.rotation)


    local myOwner = item:GetOwnerCharacter()
    

    for i = 1, #colliders do
        

        local v = colliders[i]

        
        

        local go = v.vObject

        local playSound = true
        if contains(go) then
            playSound = false
        else
            add(go) 
        end

        if myOwner ~= go then

            local character = go:Cast("Character") 
            if not character then
                -- 캐릭터가  아니면 Add Force 를 하자. 
                if v.attachedRigidbody then
                    local to = v.attachedRigidbody.transform.position + Vector3(0, 1, 0)
                    local direct = to - item.transform.position
                    local f = direct.normalized * this.power

                    v.attachedRigidbody:AddForce(f, VFramework.ForceMode.Impulse)

                    if this.hitSound and playSound then
                        soundService:Play(this.hitSound)
                    end

                end

                
            else
                -- 캐릭터이면 Knockback 를 하고
                local to = v.attachedRigidbody.transform.position + Vector3(0, 1, 0)
                local direct = to - item.transform.position
                local f = direct.normalized * this.power

                character:KnockBack(f,  VFramework.ForceMode.Impulse, this.powerMaxSpeed)

                if this.hitSound and playSound then
                    soundService:Play(this.hitSound)
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
