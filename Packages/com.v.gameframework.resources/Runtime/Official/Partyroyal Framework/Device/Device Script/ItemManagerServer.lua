
local this = __CREATOR__.new()

local serviceApi
local script

local playerService


function this.OnStart()    
    
    serviceApi = this.serviceApi        
    
    script = this.scriptObject   

    playerService = serviceApi.playerService

    
    if playerService then
        
        playerService.OnDestroyCharacter:AddListener(this.OnDestroyCharacter) 
        
        
    end


end 




function this.OnDestroyCharacter(player)

    local equipedItem = player.character:GetEquippedItem()

    if equipedItem == nil then
        return
    end


    if equipedItem.amount <= 0 and equipedItem.isAmountInfinite == false then
        return 
    end

     player.character:UnEquipItem(equipedItem, false)

end


