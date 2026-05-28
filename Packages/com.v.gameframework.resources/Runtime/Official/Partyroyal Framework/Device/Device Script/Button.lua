local this = __CREATOR__.new()

--this.OnClickEvent = __EX_VARIABLE__.event(_VOBJECT_.vobject(), _VOBJECT_.vobject())
this.OnClickEvent = __EX_VARIABLE__.event()

local serviceApi
local script
local world
local soundService

function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject
    world = serviceApi.world
    soundService = serviceApi.soundService    
end

function this.OnCollisionEnter(collision)    

    script:Log("Collide")
    if collision == nil then return end

    local obj = collision.vObject or collision
    if obj == nil then return end

    local character = obj:Cast("Character")
    if character == nil then return end

    if this.OnClickEvent ~= nil then
        --this.OnClickEvent:Call(script.parent, obj)
        this.OnClickEvent:Call()
    end
end