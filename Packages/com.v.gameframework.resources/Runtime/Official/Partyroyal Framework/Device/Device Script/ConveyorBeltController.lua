local this = __CREATOR__.new()

local serviceApi
local script
local playerService

this.AutoStart = __EX_VARIABLE__.bool(true)
this.Force = __EX_VARIABLE__.float()
this.FlowSpeedFactor = __EX_VARIABLE__.float(0.1)

local registeredPlayers = {}
local isPlaying = true
local cachedSlotScripts = {}

local function BindSlotScripts(root)
    if root == nil then return end
    local count = root.childCount or 0
    for i = 0, count - 1 do
        local child = root:GetChild(i)
        if child ~= nil then
            if child.name == "ConveyorBeltSlotScript" then
                local slotScript = child:GetLua()
                if slotScript ~= nil and cachedSlotScripts[slotScript] ~= true then
                    cachedSlotScripts[slotScript] = true
                    slotScript.SetConveyorBeltController(script)
                end
            end

            local isVObj = select(1, child:CastByType(typeof(VFramework.WorldObject)))
            if isVObj and child.childCount > 0 then
                BindSlotScripts(child)
            end
        end
    end
end

local function RemoveRegisteredPlayer(player)
    if player == nil then return end
    registeredPlayers[player] = nil
end

local function FindSlotScriptIndex(slotScripts, targetSlotScript)
    if slotScripts == nil or targetSlotScript == nil then return nil end
    for i, slotScript in ipairs(slotScripts) do
        if slotScript == targetSlotScript then
            return i
        end
    end
    return nil
end

local function OnDestroyCharacter(player)
    RemoveRegisteredPlayer(player)
end

local function OnPlayerLeave(player)
    RemoveRegisteredPlayer(player)
end

function this.OnStart()
    serviceApi = this.serviceApi
    script = this.scriptObject
    playerService = serviceApi and serviceApi.playerService or nil
    isPlaying = this.AutoStart

    if playerService then
        playerService.OnDestroyCharacter:AddListener(OnDestroyCharacter)
        playerService.OnPlayerLeave:AddListener(OnPlayerLeave)
    end

    BindSlotScripts(script and script.parent or nil)

    if this.AutoStart then
        this.Play()
    else
        this.Stop()
    end
end

function this.OnFixedUpdate(deltaTime)
    if isPlaying == false then return end
    for player, playerData in pairs(registeredPlayers) do
        if player == nil or player.character == nil then
            registeredPlayers[player] = nil
        elseif playerData ~= nil then
            local slotScripts = playerData.slotScripts
            if slotScripts == nil or #slotScripts == 0 then
                RemoveRegisteredPlayer(player)
            else
                local lastSlotScript = playerData.lastSlotScript
                if lastSlotScript == nil then
                    lastSlotScript = slotScripts[#slotScripts]
                    playerData.lastSlotScript = lastSlotScript
                end
                
                if lastSlotScript ~= nil and lastSlotScript.GetDirectionForce ~= nil then
                    local force = lastSlotScript.GetDirectionForce()
                    if force ~= nil then
                        player.character:AddForce(force, VFramework.ForceMode.Impulse)
                    end
                end
            end
        end
    end
end

function this.OnDestroy()
    if playerService then
        playerService.OnDestroyCharacter:RemoveListener(OnDestroyCharacter)
        playerService.OnPlayerLeave:RemoveListener(OnPlayerLeave)
    end    
end

function this.OnDisable()
    registeredPlayers = {}
end

function this.Register(player, slotScript)
    if player == nil or slotScript == nil then return end

    local playerData = registeredPlayers[player]
    if playerData == nil then
        playerData = {
            slotScripts = {},
            lastSlotScript = nil,
        }
        registeredPlayers[player] = playerData
    end

    local slotScripts = playerData.slotScripts
    if slotScripts == nil then
        slotScripts = {}
        playerData.slotScripts = slotScripts
    end

    local existingIndex = FindSlotScriptIndex(slotScripts, slotScript)
    if existingIndex ~= nil then
        table.remove(slotScripts, existingIndex)
    end

    table.insert(slotScripts, slotScript)
    playerData.lastSlotScript = slotScript
end

function this.UnRegister(player, slotScript)
    local playerData = registeredPlayers[player]
    if playerData == nil then return end

    if slotScript == nil then
        return
    end

    local slotScripts = playerData.slotScripts
    if slotScripts == nil then
        RemoveRegisteredPlayer(player)
        return
    end

    local index = FindSlotScriptIndex(slotScripts, slotScript)
    if index ~= nil then
        table.remove(slotScripts, index)            
        if #slotScripts > 0 then
            if playerData.lastSlotScript == slotScript then                
                playerData.lastSlotScript = slotScripts[#slotScripts]
            end            
        end
    end

    if #slotScripts == 0 then
        RemoveRegisteredPlayer(player)
    end
end

function this.UnRegisterAllBySlot(slotScript)
    if slotScript == nil then return end

    local players = {}
    for player, playerData in pairs(registeredPlayers) do
        if player ~= nil and playerData ~= nil then
            local slotScripts = playerData.slotScripts
            if FindSlotScriptIndex(slotScripts, slotScript) ~= nil then
                table.insert(players, player)
            end
        end
    end

    for i = 1, #players do
        this.UnRegister(players[i], slotScript)
    end
end

__EX_FUNCTION__(this)
function this.Play()
    isPlaying = true
    for slotScript, _ in pairs(cachedSlotScripts) do
        if slotScript ~= nil then
            slotScript.FlowPlay()
        end
    end
end

__EX_FUNCTION__(this)
function this.Stop()
    isPlaying = false
    for slotScript, _ in pairs(cachedSlotScripts) do
        if slotScript ~= nil then
            slotScript.FlowStop()
        end
    end
end

function this.GetForce()
    return this.Force
end

function this.GetFlowSpeed()
    return this.Force * this.FlowSpeedFactor
end
