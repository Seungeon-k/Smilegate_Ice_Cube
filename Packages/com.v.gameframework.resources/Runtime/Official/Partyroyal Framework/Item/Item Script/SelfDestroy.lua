

local this = __CREATOR__.new()

local serviceApi
local script

local playerService
local world



this.time = __EX_VARIABLE__.float(3)

local currentTime = 0
local active = false

function this.OnStart()    
    serviceApi = this.serviceApi        
    script = this.scriptObject   


    world = serviceApi.world

    
    active = true
    currentTime = this.time
    
end    



function this.OnUpdate(deltaTime)

    if active == false then return end

    currentTime = currentTime - deltaTime

    if currentTime <= 0 then
        script.parent:Destroy()
    end

end

