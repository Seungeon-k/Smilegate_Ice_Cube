UGC_SampleAPI = {}

function UGC_SampleAPI.GetTable()
    local this = {}
    local GameObject = UnityEngine.GameObject
    local thisGameObject
    local thisLuaComponent
    local thisTransform

    local LogText = nil
    local DropDownObj = nil
    local ProjectType = nil


    -- Awake
    function this.Awake(luaComponentInfo)
        thisGameObject = luaComponentInfo.TargetGameObject
        thisTransform = luaComponentInfo.TargetTransform
        thisLuaComponent = luaComponentInfo.Owner
    end

    -- Start is called before the first frame update
    function this.Start()
        LogText = thisGameObject.transform:Find("BackGround/LogText/Text").gameObject:GetComponent("Text")
        DropDownObj = thisGameObject.transform:Find("BackGround/Dropdown").gameObject:GetComponent("Dropdown")
        DropDownObj.onValueChanged:AddListener(this.OnChoiceClick)

       
        EventCenter.StartListenToEvent(this.OnGetGraphicOptionEvent, typeof(GetGraphicOptionEvent))
        EventCenter.StartListenToEvent(this.OnGetSoundOptionEvent, typeof(GetSoundOptionEvent))
        LogText.text = "NONE"
    end

    function this.OnMatchAPIOpenDownloadConfirmUIEvent(ugcTitle, sizeMB, duration, ugcId)
        local str = "OnMatchAPIOpenDownloadConfirmUIEvent"
        dataLogText.text = str
    end

    function this.OnDestroy()
        EventCenter.StopListenToEvent(this.OnGetGraphicOptionEvent, typeof(GetGraphicOptionEvent))
        EventCenter.StopListenToEvent(this.OnGetSoundOptionEvent, typeof(GetSoundOptionEvent))
        LogText.text = "NONE"
    end

    function this.OnGetGraphicOptionEvent(Option)
        str = "OnGetGraphicOptionEvent"
        dataLogText.text = str
    end

    function this.OnGetSoundOptionEvent(Vol,Mute)
        str = "OnGetSoundOptionEvent Call"
        dataLogText.text = str
    end



    function this.OnChoiceClick(value)
        if value == 0 then
            LogText.text = "NONE"
        elseif value == 1 then
        elseif value == 2 then
        elseif value == 3 then
        elseif value == 4 then
        elseif value == 5 then
        elseif value == 6 then
        elseif value == 7 then
        elseif value == 8 then
        elseif value == 9 then
        end
    end





    return this
end
