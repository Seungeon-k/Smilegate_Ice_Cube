

local this = __CREATOR__.new()

local serviceApi
local script

local playerService
local physicService
local world



this.Automatic = __EX_VARIABLE__.bool(false)
this.Repeat = __EX_VARIABLE__.bool(false)
this.SpawnRange = __EX_VARIABLE__.float(0)
this.RandomSpawn = __EX_VARIABLE__.bool(false)
this.DropOnSpawn = __EX_VARIABLE__.bool(false)
this.MaxCount = __EX_VARIABLE__.int(10)
this.PerSpawn = __EX_VARIABLE__.int(1)
this.DelayTime = __EX_VARIABLE__.float(0)
this.Spawnitem = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())


this.ActivateSpawnerOnEvent = __EX_VARIABLE__.event()

this.DespawnOnEvent = __EX_VARIABLE__.event()


local IsPlayingSpawn = false 
local Index = 0
local CurrentTime = 0  
local SpawnCountFull = false 

--this.SpawnList = {}
local SpawnItems
local Root
local BeforeCount = 0


local init = false
this.CurrentIndex = 1  

function this.OnStart()

    if init == true then return end 
    init = true 

    serviceApi = this.serviceApi        
    script = this.scriptObject   

    math.randomseed(os.time())
    

    playerService = serviceApi.playerService
    physicService = serviceApi.physicsService

    world = serviceApi.world

    this.SpawnList = this.scriptObject.parent:Find("Spawn List")
    SpawnItems = this.Spawnitem
    Root = script.parent



    if this.Automatic == true then

        this.StartAction()

    end

    
end    



function this.OnUpdate(deltaTime)




    if IsPlayingSpawn == false then 
         return 
    end

    if this.SpawnList.childCount == 0 and BeforeCount > 0 then
        BeforeCount = 0
        this.DespawnOnEvent:Call()
    end

    CurrentTime = CurrentTime - deltaTime

    if CurrentTime <= 0 then

        CurrentTime = this.DelayTime

        for i = 1, this.PerSpawn do
        
            this.CheckSpawnCount()

            if SpawnCountFull == false then
                this.SpawnItem()

            end
        end
        
        
    end

    BeforeCount = this.SpawnList.childCount

end

--=======================================================

local function randomPointInCircle(radius)
    -- 각도 (0 ~ 2π)
    local angle = math.random() * 2 * math.pi
    
    -- 반지름 (0 ~ radius) 
    -- √(random) 을 곱해야 균등 분포
    local r = math.sqrt(math.random()) * radius

    local x = math.cos(angle) * r
    local z = math.sin(angle) * r
    return x, z
end



function this.SpawnItem()

    local value 

    if this.RandomSpawn == true then
        value = math.random(1, #SpawnItems)
    else
        value = this.CurrentIndex
        this.CurrentIndex = this.CurrentIndex + 1
        if this.CurrentIndex > #SpawnItems then
            this.CurrentIndex = 1 -- 끝까지 갔다면 다시 처음으로
        end
    end

    if SpawnItems[value] == nil then return end

    local x, z = randomPointInCircle(this.SpawnRange)
    local spawnPos = this.SpawnList.transform.position
    local pos = Vector3(x + spawnPos.x, spawnPos.y, z + spawnPos.z)

    --local th = world:Instantiate(SpawnItems[value], Root.transform.position, Quaternion(0,0,0,1))
    local th = world:Instantiate(SpawnItems[value], pos, Quaternion(0,0,0,1))
    th:SetParent(this.SpawnList)
    th.transform.localPosition = Vector3(x, 0, z)

    local spawnedItem = th:Cast("Item")
    if spawnedItem then
        spawnedItem.dropOnSpawn = this.DropOnSpawn

    end

    this.ActivateSpawnerOnEvent:Call()
end

function this.StartAction()

    if IsPlayingSpawn == false then 
        IsPlayingSpawn = true 
        Index = 0
        CurrentTime = 0


    end

end


function this.CheckSpawnCount()

    if this.SpawnList.childCount >= this.MaxCount then
        SpawnCountFull = true
    else
        SpawnCountFull = false
    end

    
end


--=======================================================


__EX_FUNCTION__(this)
function this.ItemSpawned()

    this.SpawnItem()

end


__EX_FUNCTION__(this)
function this.SpawnItemDelete()

    local count = this.SpawnList.childCount
	if count == 0 then return end

    local children = {}
    for i = 0, count - 1 do
		local child = this.SpawnList:GetChild(i)
        table.insert(children, child)
    end

    for _, child in ipairs(children) do
        if child ~= nil then
            child:Destroy()
        end
    end

end
