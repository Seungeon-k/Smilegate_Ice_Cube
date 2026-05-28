local this = __CREATOR__.new()

local script

this.OnCollisionEvent = __EX_VARIABLE__.event(_VOBJECT_.vobject())

function this.OnStart()
    script = this.scriptObject
end

function this.OnCollisionEnter(collision)
    if collision == nil then return end
    if this.OnCollisionEvent == nil then return end

    local vObj = collision.vObject
    if vObj == nil then return end

    --local character = obj:Cast("Character")
    --if character == nil then return end
    
    this.OnCollisionEvent:Call(vObj)
end
