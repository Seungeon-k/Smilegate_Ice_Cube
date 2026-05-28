
local this = __CREATOR__.new()

this.activeBoundary = _VCOMPONENT_.collider()
this.rushingScript = _VOBJECT_.script():lua()

function this.OnTriggerExit(collider)
    if collider == this.activeBoundary then
        this.rushingScript.OnBoundaryExit()
    end
end

function this.OnCollisionEnter(collision)
    this.rushingScript.OnCollisionEnter(collision)    
end

function this.OnCollisionExit(collision)
    this.rushingScript.OnCollisionExit(collision)    
end