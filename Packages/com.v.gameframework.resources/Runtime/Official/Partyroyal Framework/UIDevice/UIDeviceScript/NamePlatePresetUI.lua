
   local this = __CREATOR__.new()

   this.TargetTracker = __EX_VARIABLE__.vobject.targetTracker()
   this.PlayerName = __EX_VARIABLE__.component.text()

   this.heartMore = __EX_VARIABLE__.vobject()
   this.heartCount = __EX_VARIABLE__.component.text()
   this.heartIcon = __EX_VARIABLE__.vobject()

   this.myArrow = __EX_VARIABLE__.vobject()

   this.LifeIcons = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())

   local targetPlayer

   local function updatePlayerLife(playerLife)
      if playerLife > #this.LifeIcons then

         this.heartMore:SetActive(true)
         this.heartIcon:SetActive(false)

         this.heartCount.text = tostring(playerLife)

      else

         this.heartMore:SetActive(false)
         this.heartIcon:SetActive(true)

         for index, lifeIcon in ipairs(this.LifeIcons) do
            lifeIcon:SetActive(index <= playerLife)
         end
      end
      
   end

   local function setTargetPlayer(player)
      targetPlayer = player

      if targetPlayer then
         this.PlayerName.text = targetPlayer.nickname
         this.TargetTracker:SetTargetObject(targetPlayer.character)

         this.myArrow:SetActive(targetPlayer.isLocalPlayer)

         if not targetPlayer.isLocalPlayer then
            this.PlayerName.color = Color.white
         end
      end
   end

   function this.OnStart()
      for _, lifeIcon in ipairs(this.LifeIcons) do
         lifeIcon:SetActive(false)
      end

      this.heartMore:SetActive(false)
      this.heartIcon:SetActive(false)
   end
   
   function this.OnPlayerSetup(player)
      setTargetPlayer(player)
   end   

   function this.SetPlayerLife(player, life)
      if targetPlayer == nil or player == nil then
         return
       end

      if player.id == targetPlayer.id then
         updatePlayerLife(life)
      else
         print('mismatch player id')
      end
   end
    
