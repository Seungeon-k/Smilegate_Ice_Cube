print("UgcMatchTest_Lua");

UgcMatchTest_Lua = {}

function UgcMatchTest_Lua.GetTable()
    local this = {}
    local GameObject = UnityEngine.GameObject
    local thisGameObject
    local thisLuaComponent
    local thisTransform

    local exitGameBtn = nil
    local getGroupUgcListBtn = nil
    local getUgcDetailBtn = nil
    local createMatchBtn = nil
    local startMatchBtn = nil
    local getMatchUgcBtn = nil
    local getQuickMatchUgcBtn = nil
    local isMatchingBtn = nil
    local cancelMatchBtn = nil
    local askCancelMatchForMoveBtn = nil

    local logText = nil
    local dataLogText = nil

    local getGroupUgcList_Dropdown = nil
    local getGroupUgcList_Field1 = nil
    local getGroupUgcList_Field2 = nil

    local getUgcDetail_Field1 = nil
    local getUgcDetail_Dropdown = nil

    local createMatch_Field1 = nil
    local createMatch_Field2 = nil
    local createMatch_Field3 = nil

    local startMatch_Field1 = nil
    local startMatch_Field2 = nil

    -- Awake
    function this.Awake(luaComponentInfo)
        EventCenter = USGFramework.Runtime.USGZone.EventCenter
        
        print("UgcMatchTest_Lua Awake")
        
        thisGameObject = luaComponentInfo.TargetGameObject    
        thisTransform = luaComponentInfo.TargetTransform
        thisLuaComponent = luaComponentInfo.Owner   
    end
    
    -- Start is called before the first frame update
    function this.Start()
        exitGameBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("ExitGame").UnityObject:GetComponent("Button")
        exitGameBtn.onClick:AddListener(this.ExitGame)

        getGroupUgcListBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("GetGroupUgcList").UnityObject:GetComponent("Button")
        getGroupUgcListBtn.onClick:AddListener(this.GetGroupUgcList)

        getUgcDetailBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("GetUgcDetail").UnityObject:GetComponent("Button")
        getUgcDetailBtn.onClick:AddListener(this.GetUgcDetail)

        createMatchBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("CreateMatch").UnityObject:GetComponent("Button")
        createMatchBtn.onClick:AddListener(this.CreateMatch)

        startMatchBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("StartMatch").UnityObject:GetComponent("Button")
        startMatchBtn.onClick:AddListener(this.StartMatch)

        getMatchUgcBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("GetMatchUgc").UnityObject:GetComponent("Button")
        getMatchUgcBtn.onClick:AddListener(this.GetMatchUgc)

        getQuickMatchUgcBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("GetQuickMatchUgc").UnityObject:GetComponent("Button")
        getQuickMatchUgcBtn.onClick:AddListener(this.GetQuickMatchUgc)

        isMatchingBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("IsMatching").UnityObject:GetComponent("Button")
        isMatchingBtn.onClick:AddListener(this.IsMatching)

        cancelMatchBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("CancelMatch").UnityObject:GetComponent("Button")
        cancelMatchBtn.onClick:AddListener(this.CancelMatch)

        askCancelMatchForMoveBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("AskCancelMatchForMove").UnityObject:GetComponent("Button")
        askCancelMatchForMoveBtn.onClick:AddListener(this.AskCancelMatchForMove)

        logText = thisLuaComponent:GetUnityObjectPropertyValueByName("LogText").UnityObject:GetComponent("Text")
        dataLogText = thisLuaComponent:GetUnityObjectPropertyValueByName("DataLogText").UnityObject:GetComponent("Text")

        getGroupUgcList_Dropdown = thisLuaComponent:GetUnityObjectPropertyValueByName("GetGroupUgcList_Dropdown").UnityObject:GetComponent("Dropdown")
        getGroupUgcList_Field1 = thisLuaComponent:GetUnityObjectPropertyValueByName("GetGroupUgcList_Field1").UnityObject:GetComponent("Text")
        getGroupUgcList_Field2 = thisLuaComponent:GetUnityObjectPropertyValueByName("GetGroupUgcList_Field2").UnityObject:GetComponent("Text")
        
        getUgcDetail_Field1 = thisLuaComponent:GetUnityObjectPropertyValueByName("GetUgcDetail_Field1").UnityObject:GetComponent("Text")
        getUgcDetail_Dropdown = thisLuaComponent:GetUnityObjectPropertyValueByName("GetUgcDetail_Dropdown").UnityObject:GetComponent("Dropdown")

        createMatch_Field1 = thisLuaComponent:GetUnityObjectPropertyValueByName("CreateMatch_Field1").UnityObject:GetComponent("Text")
        createMatch_Field2 = thisLuaComponent:GetUnityObjectPropertyValueByName("CreateMatch_Field2").UnityObject:GetComponent("Text")
        createMatch_Field3 = thisLuaComponent:GetUnityObjectPropertyValueByName("CreateMatch_Field3").UnityObject:GetComponent("Text")

        startMatch_Field1 = thisLuaComponent:GetUnityObjectPropertyValueByName("StartMatch_Field1").UnityObject:GetComponent("Text")
        startMatch_Field2 = thisLuaComponent:GetUnityObjectPropertyValueByName("StartMatch_Field2").UnityObject:GetComponent("Text")

        EventCenter.StartListenToEvent(this.OnMatchAPIOpenDownloadConfirmUIEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIOpenDownloadConfirmUIEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPIOpenDownloadUIEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIOpenDownloadUIEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPICloseDownloadUIEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPICloseDownloadUIEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPIUpdateDownloadProgressEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIUpdateDownloadProgressEvent)) -- string ugcId, ulong currBytes, ulong totalBytes)
        EventCenter.StartListenToEvent(this.OnMatchAPICloseUgcLobbyEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPICloseUgcLobbyEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPIStartMatchEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIStartMatchEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPICancelMatchEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPICancelMatchEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPIFailMatchEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIFailMatchEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPIUpdateMatchCountEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIUpdateMatchCountEvent)) -- int count
        EventCenter.StartListenToEvent(this.OnMatchAPIEventActiveMatchInviteEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIEventActiveMatchInviteEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPIAdditionalWaitingEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIAdditionalWaitingEvent)) -- bool isActive
        EventCenter.StartListenToEvent(this.OnMatchAPICancelMatchForMoveEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPICancelMatchForMoveEvent))
        EventCenter.StartListenToEvent(this.OnMatchAPINotifyMessageEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPINotifyMessageEvent)) -- message
    end
    
    function this.OnDestroy()
        EventCenter.StopListenToEvent(this.OnMatchAPIOpenDownloadConfirmUIEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIOpenDownloadConfirmUIEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPIOpenDownloadUIEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIOpenDownloadUIEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPICloseDownloadUIEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPICloseDownloadUIEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPIUpdateDownloadProgressEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIUpdateDownloadProgressEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPICloseUgcLobbyEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPICloseUgcLobbyEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPIStartMatchEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIStartMatchEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPICancelMatchEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPICancelMatchEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPIFailMatchEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIFailMatchEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPIUpdateMatchCountEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIUpdateMatchCountEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPIEventActiveMatchInviteEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIEventActiveMatchInviteEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPIAdditionalWaitingEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPIAdditionalWaitingEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPICancelMatchForMoveEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPICancelMatchForMoveEvent))
        EventCenter.StopListenToEvent(this.OnMatchAPINotifyMessageEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPINotifyMessageEvent))


        EventCenter.StopListenToEvent(this.OnMatchAPIDownloadUgcEvent, typeof(USGFramework.Runtime.Contents.Events.MatchAPINotifyMessageEvent))
    end

    -- Update is called once per frame
    function this.Update()
    
    end


    function this.ExitGame()
        --print("UgcMatchTest_Lua ExitGame")
        USGFramework.Runtime.Contents.CommonAction.ExitGame()
    end

    function this.GetGroupUgcList()
        local projectType = nil
        if getGroupUgcList_Dropdown.value == 0 then
            projectType = USGFramework.Runtime.Contents.APIDataStruct.UGCProjectType.Unknown
        elseif getGroupUgcList_Dropdown.value == 1 then
            projectType = USGFramework.Runtime.Contents.APIDataStruct.UGCProjectType.Arcade
        elseif getGroupUgcList_Dropdown.value == 2 then
            projectType = USGFramework.Runtime.Contents.APIDataStruct.UGCProjectType.VulcanusPro
        else
            projectType = USGFramework.Runtime.Contents.APIDataStruct.UGCProjectType.Unknown
        end

        local key = getGroupUgcList_Field1.text;
        local size = tonumber(getGroupUgcList_Field2.text);
            
        local reqData = USGFramework.Runtime.Contents.APIDataStruct.ReqGetGroupUgcList.New(projectType, key, size)  -- APIDataStruct.ReqGetGroupUgcList

        local str = "GetGroupUgcList projectType: "..tostring(projectType)..", key : "..key..", size : "..tostring(size)
        dataLogText.text = str

        USGFramework.Runtime.Contents.UgcAPI.GetGroupUgcList(this.CallBackGetGroupUgcList, reqData)
    end
    -- callback
    function this.CallBackGetGroupUgcList(resGetGourpUgcList)
        local resGetGourpUgcListData = resGetGourpUgcList -- APIDataStruct.ResGetGroupUgcList
        local str = "CallBackGetGroupUgcList"
        dataLogText.text = str
    end


    function this.GetUgcDetail()
        local ugcID = getUgcDetail_Field1.text;
        local ugcArchitectType = nil
        if getUgcDetail_Dropdown.value == 0 then
            ugcArchitectType = USGFramework.Runtime.Contents.APIDataStruct.UgcArchitectType.Unknown
        elseif getUgcDetail_Dropdown.value == 1 then
            ugcArchitectType = USGFramework.Runtime.Contents.APIDataStruct.UgcArchitectType.AOS
        elseif getUgcDetail_Dropdown.value == 2 then
            ugcArchitectType = USGFramework.Runtime.Contents.APIDataStruct.UgcArchitectType.IOS
        elseif getUgcDetail_Dropdown.value == 3 then
            ugcArchitectType = USGFramework.Runtime.Contents.APIDataStruct.UgcArchitectType.Server
        elseif getUgcDetail_Dropdown.value == 4 then
            ugcArchitectType = USGFramework.Runtime.Contents.APIDataStruct.UgcArchitectType.Project
        elseif getUgcDetail_Dropdown.value == 5 then
            ugcArchitectType = USGFramework.Runtime.Contents.APIDataStruct.UgcArchitectType.Package
        elseif getUgcDetail_Dropdown.value == 6 then
            ugcArchitectType = USGFramework.Runtime.Contents.APIDataStruct.UgcArchitectType.Windows
        else
            ugcArchitectType = USGFramework.Runtime.Contents.APIDataStruct.UgcArchitectType.Unknown
        end

        local reqData = USGFramework.Runtime.Contents.APIDataStruct.ReqGetUgcDetail.New(ugcID, ugcArchitectType)  -- APIDataStruct.ReqGetUgcDetail

        local str = "ugcID  : "..ugcID..", ugcArchitectType: "..tostring(ugcArchitectType)
        dataLogText.text = str

        print("GetUgcDetail")
        USGFramework.Runtime.Contents.UgcAPI.GetUgcDetail(this.CallBackGetUgcDetail, reqData)
    end
    -- callback
    function this.CallBackGetUgcDetail(resGetUgcDetail)
        local resGetUgcDetailData = resGetUgcDetail -- APIDataStruct.ResGetUgcDetail
        local str = "CallBackGetUgcDetail"
        dataLogText.text = str
    end

    function this.CreateMatch()
        local ugcID = createMatch_Field1.text
        local IsPrivate = nil
        if createMatch_Field2.text == "true" then
            IsPrivate = true
        else
            IsPrivate = false
        end
        local CheckZone = nil
        if createMatch_Field3.text == "true" then
            CheckZone = true
        else
            CheckZone = false
        end

        local req = USGFramework.Runtime.Contents.APIDataStruct.ReqCreateZone.New()  -- APIDataStruct.ReqCreateZone
        req.UgcID = ugcID -- string
        req.IsPrivate = IsPrivate -- bool
        req.CheckZone = CheckZone -- bool

        local str = "ugcID  : "..ugcID..", IsPrivate: "..tostring(IsPrivate)..", CheckZone: "..tostring(CheckZone)
        dataLogText.text = str
        USGFramework.Runtime.Contents.MatchAPI.CreateMatch(req)
    end

    function this.StartMatch()
        local ugcID = startMatch_Field1.text
        local CheckZone = nil
        if startMatch_Field2.text == "true" then
            CheckZone = true
        else
            CheckZone = false
        end

        local req = USGFramework.Runtime.Contents.APIDataStruct.ReqStartMatch.New()  -- APIDataStruct.ReqStartMatch
        req.UgcID = ugcID -- string
        req.CheckZone = CheckZone -- bool

        local str = "ugcID  : "..ugcID..", CheckZone: "..tostring(CheckZone)
        dataLogText.text = str
        USGFramework.Runtime.Contents.MatchAPI.StartMatch(req)
    end

    function this.GetMatchUgc()
        local str = "GetMatchUgc"
        dataLogText.text = str
        local UgcDetail = USGFramework.Runtime.Contents.MatchAPI.GetMatchUgc()
        return UgcDetail
    end

    function this.GetQuickMatchUgc()
        local str = "GetQuickMatchUgc"
        dataLogText.text = str
        local UgcBase = USGFramework.Runtime.Contents.MatchAPI.GetQuickMatchUgc()
        return UgcBase
    end

    function this.IsMatching()
        local str = "IsMatching"
        dataLogText.text = str
        local isMatching = USGFramework.Runtime.Contents.MatchAPI.IsMatching()
        return isMatching
    end

    function this.CancelMatch()
        local str = "CancelMatch"
        dataLogText.text = str
        USGFramework.Runtime.Contents.MatchAPI.CancelMatch()
    end

    function this.AskCancelMatchForMove()
        local str = "AskCancelMatchForMove"
        dataLogText.text = str
        USGFramework.Runtime.Contents.MatchAPI.AskCancelMatchForMove()
    end

    -----------------------------------------------------------
    -- string ugcTitle, float sizeMB, float duration, string ugcId
    function this.OnMatchAPIOpenDownloadConfirmUIEvent(ugcTitle, sizeMB, duration, ugcId)
        local str = "OnMatchAPIOpenDownloadConfirmUIEvent"
        dataLogText.text = str
    end
    -- UgcDetail    
    function this.OnMatchAPIOpenDownloadUIEvent(UgcDetail)
        local str = "OnMatchAPIOpenDownloadUIEvent"
        dataLogText.text = str
    end



    function this.OnMatchAPIDownloadUgcEvent()
        USGFramework.Runtime.Contents.APIDataStruct.ReqDownloadUgc.New(1234567)

        USGFramework.Runtime.Contents.MatchAPI.DownloadUgc()
    end



    function this.OnMatchAPICloseDownloadUIEvent()
        local str = "OnMatchAPICloseDownloadUIEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPIUpdateDownloadProgressEvent(ugcId, currBytes, totalBytes)
        local str = "OnMatchAPIUpdateDownloadProgressEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPICloseUgcLobbyEvent()
        local str = "OnMatchAPICloseUgcLobbyEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPIStartMatchEvent()
        local str = "OnMatchAPIStartMatchEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPICancelMatchEvent()
        local str = "OnMatchAPICancelMatchEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPIFailMatchEvent()
        local str = "OnMatchAPIFailMatchEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPIUpdateMatchCountEvent(count)
        local str = "OnMatchAPIUpdateMatchCountEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPIEventActiveMatchInviteEvent()
        local str = "OnMatchAPIEventActiveMatchInviteEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPIAdditionalWaitingEvent(isActive)
        local str = "OnMatchAPIAdditionalWaitingEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPICancelMatchForMoveEvent()
        local str = "OnMatchAPICancelMatchForMoveEvent"
        dataLogText.text = str
    end
    function this.OnMatchAPINotifyMessageEvent(message)
        local str = "OnMatchAPINotifyMessageEvent"
        dataLogText.text = str
    end

    return this
end