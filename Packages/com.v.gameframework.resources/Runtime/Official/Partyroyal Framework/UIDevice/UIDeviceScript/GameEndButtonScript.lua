
   local this = __CREATOR__.new()   

   local scriptObject
   local serviceApi
   local inputServiceApi = nil
   local inputGate = nil
   local inputGameplayType = nil
   local inputCameraType = nil

   this.ForceQuitDelay = __EX_VARIABLE__.float()

   this.UI = __EX_VARIABLE__.vobject()
   this.TimeSlider = _VCOMPONENT_.slider()
   this.TimeText = _VCOMPONENT_.text()

   function this.OnAwake()
      this.UI:SetActive(false)
   end

   function this.OnStart()

      scriptObject = this.scriptObject
      serviceApi = this.serviceApi
      inputServiceApi = serviceApi.inputService    
      inputGate = inputServiceApi.gate

      inputGameplayType = VFramework.InputChannel.Gameplay
      inputCameraType = VFramework.InputChannel.Camera
        
   end

   local function nicelyExitGame()

      local loopCount = 0
      while loopCount < this.ForceQuitDelay do

         this.TimeSlider.value = loopCount / this.ForceQuitDelay
         this.TimeText.text = math.floor(this.ForceQuitDelay - loopCount)

         VFramework.WaitForSeconds(1)

         loopCount = loopCount + 1

      end
      
      this.ExitGame()
   end

   __EX_FUNCTION__(this)
   function this.ExitGame()
      serviceApi.room:Exit()
   end

   __EX_FUNCTION__(this)
   function this.ShowUI()

      this.UI:SetActive(true)      
      scriptObject:AsyncCall(nicelyExitGame)      
   end

   __EX_FUNCTION__(this)
   function this.HideUI()

      this.UI:SetActive(false)      

   end
    
