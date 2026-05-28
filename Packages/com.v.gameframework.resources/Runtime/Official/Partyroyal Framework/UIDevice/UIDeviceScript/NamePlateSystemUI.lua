
   local this = __CREATOR__.new()

   this.TargetTracker = __EX_VARIABLE__.vobject.targetTracker()
   this.PlayerName = __EX_VARIABLE__.component.text()

   this.myArrow = __EX_VARIABLE__.vobject()

   local targetPlayer

   local function SetTargetPlayer(player)
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

   function this.OnPlayerSetup(player)
      SetTargetPlayer(player)
   end
    
