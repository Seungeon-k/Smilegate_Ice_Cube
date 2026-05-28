

local this = __CREATOR__.new()

local serviceApi
local script

local playerService
local soundService

local inputService
local actionButtons


this.Slot1Items = __EX_VARIABLE__.list(__EX_VARIABLE__.string())
this.Slot2Items = __EX_VARIABLE__.list(__EX_VARIABLE__.string())
this.Slot3Items = __EX_VARIABLE__.list(__EX_VARIABLE__.string())
this.ActionBtns = __EX_VARIABLE__.vobject.script():lua()
this.pickupSound = __EX_VARIABLE__.asset.audioClip()




function this.OnStart()    
    serviceApi = this.serviceApi        
    script = this.scriptObject   
    actionButtons = this.ActionBtns
    

    this.RefreshSlotConfigFromGlobals()

    playerService = serviceApi.playerService
    inputService = serviceApi.inputService
    soundService = serviceApi.soundService

    if playerService then
        
        playerService.OnPickedUpItem:AddListener(this.OnPicked) 
        playerService.OnItemUseFinished:AddListener(this.OnItemFinished) 
        playerService.OnItemAutoUsed:AddListener(this.OnItemAutoUsed) 
        playerService.OnCreateCharacter:AddListener(this.OnCreateCharacter) 
        playerService.OnDestroyCharacter:AddListener(this.OnDestroyCharacter) 
        playerService.OnAllItemsRemoved:AddListener(this.OnAllItemsRemoved) 
        playerService.OnItemRemoved:AddListener(this.OnItemRemoved) 

        
        
    end

    if inputService then
        inputService.OnButtonActionEvent:AddListener(this.OnButtonEvent)
    end

end    



----------------------------------------------------------------
-- 슬롯 구성(아이템 ID 리스트) → 해시셋으로도 보관해 빠른 판별
----------------------------------------------------------------
this._cfg = {
    lists = { [1]={}, [2]={}, [3]={} },
    sets  = { [1]={}, [2]={}, [3]={} },
}

local function rebuild_set(slot)
    local set = {}
    for _, id in ipairs(this._cfg.lists[slot] or {}) do
        if id and id ~= "" then set[id] = true end
    end
    this._cfg.sets[slot] = set
end




    --  Slot{1..4}Items 를 읽어와 반영
function this.RefreshSlotConfigFromGlobals()
    
    this._cfg.lists[1] = (this.Slot1Items or {})
    this._cfg.lists[2] = (this.Slot2Items or {})
    this._cfg.lists[3] = (this.Slot3Items or {})
    
    for s=1,4 do rebuild_set(s) end
end


    -- 슬롯 판별: 위에서 만든 sets 사용
local function resolve_slot_by_lists(itemId)
    if not itemId or itemId=="" then return nil end
    for s=1,4 do
        if this._cfg.sets[s][itemId] then return s end
    end
    return nil
end



----------------------------------------------------------------
--  플레이어별 상태 저장소
----------------------------------------------------------------
  local state = {
    recent = { [1]={}, [2]={}, [3]={} } -- 각 슬롯의 최근 아이템ID 스택(앞=최신)
  }



    -- 유틸


local function update_slot_button(slot)
    
    
    if not actionButtons then 
      
        return false 
    end
    local item = state.recent[slot] and state.recent[slot][1] or nil
    if not item then
        actionButtons.DisableActionButton(slot)
        return true 
    elseif item.amount <= 0 and item.isAmountInfinite == false then
        actionButtons.DisableActionButton(slot)
        return true     
    end

    

    local currentCoolTime = item.coolTime; 
    actionButtons.EnableActionButton(slot, item.itemIcon, item.amount, item.isAmountInfinite, item.coolTime)  
    --actionButtons.SetCoolTimeOnActionButton(slot, item.coolTime, currentCoolTime)
    


end


local function push_front_unique(slot, item)
    
    local list = state.recent[slot]
    local rm=nil; for i,v in ipairs(list) do if v.itemID==item.itemID then rm=i break end end
    if rm then table.remove(list, rm) end
    table.insert(list, 1, item)
    update_slot_button(slot)
end


local function remove_id(slot, item)
    local list = state.recent[slot]
    for i,v in ipairs(list) do 
        if v.itemID==item.itemID then 
            table.remove(list,i) 
            return true 
        end 
    end
    return false
end

local function remove_id_by_itemId(slot, itemId)
    local list = state.recent[slot]
    for i,v in ipairs(list) do 
        if v.itemID==itemId then 
            table.remove(list,i) 
            return true 
        end 
    end
    return false
    
end


----------------------------------------------------------------
--  Item 동작
----------------------------------------------------------------


local buttonActions = {
    ["Action 1"] = function(buttonState)
        PressButton(1, buttonState)
    end,
    ["Action 2"] = function(buttonState)
        PressButton(2, buttonState)
    end,
    ["Action 3"] = function(buttonState)
        PressButton(3, buttonState)
    end
}


function PressButton(slot, buttonState)

    if not actionButtons then 
      
        return false 
    end

    if actionButtons.IsActionButtonVaild(slot) == false then return false end

    local item = state.recent[slot] and state.recent[slot][1] or nil

     if not item then 

        return false 
    end

    

    local localPlayer = playerService.localPlayer

    if not localPlayer or not localPlayer.character then return false end

    local equipedItem = localPlayer.character:GetEquippedItem()

    if item.amount <= 0 and item.isAmountInfinite == false then
        return false
    end

    if localPlayer.character:IsItemInUse() then
        return false
    end

    if item.buttonActionTrigger ~= buttonState then
        if buttonState == VFramework.ButtonState.Press then
            if item ~= equipedItem then
                localPlayer.character:EquipItem(item)
            end
        end
        return false
    end

    if item.isAmountInfinite == false then
         item.amount = item.amount - 1 
         actionButtons.SetCount(slot, item.amount)
    end
   

    -- coolTime Set
    actionButtons.SetCoolTimeOnActionButton(slot, item.coolTime, item.coolTime)



    localPlayer.character:UseItem(item)

    return true 


end



function this.OnButtonEvent(actionName, buttonState)

     if buttonActions[actionName] then
            buttonActions[actionName](buttonState)   
        end
    
  
end



----------------------------------------------------------------
-- 플레이어 이벤트
----------------------------------------------------------------
function this.OnPicked(player, item)
    
    if not player or player.isLocalPlayer==false then
        return 
    end

    
    if not item or item.itemID=="" then 
        return 
    end

    
    local slot = resolve_slot_by_lists(item.itemID); 
    if not slot then
        return 
    end

    if this.pickupSound then
        soundService:Play(this.pickupSound)
    end

    

    --local p = ensure_player(player)
    push_front_unique(slot, item)
    
    

    this.EquipMostRecent(player, slot)
    
end

function this.OnItemFinished(player, item)

    if not player or player.isLocalPlayer==false then
        return 
    end

    if not item or item.itemID=="" then 
        return 
    end
    local slot = resolve_slot_by_lists(item.itemID); 
    if not slot then
        return 
    end

    local refreshButton = false 
    if item.amount <= 0 and item.isAmountInfinite == false then
        refreshButton = true
        remove_id(slot, item)
        if player.character then
            player.character:UnEquipItem(item, true)
        end
    end
    
    
    this.EquipMostRecent(player, slot)
    if refreshButton then
         update_slot_button(slot)
    end
    
end

function this.OnItemAutoUsed(player, item)

    if not player or player.isLocalPlayer==false then
        return 
    end

    if not item or item.itemID=="" then 
        return 
    end

    if item.amount > 0 and item.isAmountInfinite == false then
        
        item.amount = item.amount - 1 
    end

    local slot = resolve_slot_by_lists(item.itemID); 
    if not slot then
        return 
    end

    if item.amount <= 0 and item.isAmountInfinite == false then
        remove_id(slot, item)
        if player.character then
            player.character:UnEquipItem(item, true)
        end
        
    end


    this.EquipMostRecent(player, slot)
    update_slot_button(slot)

    -- actionButtons.SetCount(slot, item.amount)
    -- actionButtons.SetCoolTimeOnActionButton(slot, item.coolTime, item.coolTime)


end

function this.OnAllItemsRemoved(player)
    if not player or player.isLocalPlayer==false then
        return 
    end

    state.recent[1] = {}
    state.recent[2] = {}
    state.recent[3] = {}

    update_slot_button(1)
    update_slot_button(2)
    update_slot_button(3)

    
end

function this.OnItemRemoved(player, itemId)
    if not player or player.isLocalPlayer==false then
        return 
    end

    local slot = resolve_slot_by_lists(itemId); 
    if not slot then
        return 
    end

    local re = remove_id_by_itemId(slot, itemId)

    if re == true then
        this.EquipMostRecent(player, slot)
        update_slot_button(slot)
    end
    
    
end


function this.OnCreateCharacter(player)
    if not player or player.isLocalPlayer==false then
        return 
    end
    
    update_slot_button(1)
    update_slot_button(2)
    update_slot_button(3)

end

function this.OnDestroyCharacter(player)

    if not player or player.isLocalPlayer==false or not player.character then
        return 
    end    

    local item = player.character:GetEquippedItem()

    if item and (item.amount <= 0 and item.isAmountInfinite == false) then
        this.OnItemFinished(player, item)
        
    end

    
end

----------------------------------------------------------------
-- API (플레이어 동작)
----------------------------------------------------------------







function this.EquipMostRecent(player, slot)


    --local p = ensure_player(player)
    local item = state.recent[slot] and state.recent[slot][1] or nil

    if not item then 

        return false 
    end
    if item.amount <= 0 and item.isAmountInfinite == false then
        remove_id(slot, item)

        return false
    end

    if not player.character then

        return false 
    end


    
    return player.character:EquipItem(item)
end


function this.SelectSlot(player, slot)
    return this.EquipMostRecent(player, slot)
end


function this.EquipById(player, item)
    if not item or item.itemID=="" then return false end
    -- 안전장치: 해당 itemId가 그 슬롯 리스트에 포함되어야 함
    if resolve_slot_by_lists(item.itemId) ~= slot then return false end
    --local p = ensure_player(player)
    local slot = resolve_slot_by_lists(item.itemID); 
    if not slot then
        return 
    end
    if item.amount <= 0 and item.isAmountInfinite == false then return false end
    push_front_unique(slot, item)
     if not player.character then
        return false 
    end
    return player.character:EquipItem(item)
end



 


