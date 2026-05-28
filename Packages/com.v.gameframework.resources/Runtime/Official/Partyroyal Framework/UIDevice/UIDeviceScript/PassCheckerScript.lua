
   local this = __CREATOR__.new()   

   this.RequiredPlayers = __EX_VARIABLE__.int()

   this.OnPlayerPassed = __EX_VARIABLE__.event(_VOBJECT_.player())
   this.OnRequiredPlayersPassed = __EX_VARIABLE__.event()
   this.OnAllPlayersPassed  = __EX_VARIABLE__.event()

   local passedPlayerMap = {}

   local function countMap(t)
      local n = 0
      for _ in pairs(t) do
         n = n + 1
      end
      return n
   end

   function this.OnTriggerEnter(collider)
      local _, character = collider.vObject:CastByType(typeof(VFramework.Character))
      if character == nil then
         return
      end

      local playerId = character.player.id

      local passedCount = passedPlayerMap[playerId] or 0
      local currentPassCount = passedCount + 1

      passedPlayerMap[playerId] = currentPassCount

      this.OnPlayerPassed:Call(character.player)      

      local passedPlayerCount = countMap(passedPlayerMap)
      local playerCount = this.serviceApi.playerService:GetPlayerCount()

      if this.RequiredPlayers > 0 and this.RequiredPlayers == passedPlayerCount then
         this.OnRequiredPlayersPassed:Call()
      end

      if passedPlayerCount >= playerCount then
         this.OnAllPlayersPassed:Call()
      end

      print('trigger enter: '..tostring(playerId)..' / '..tostring(currentPassCount))
    
   end
    
