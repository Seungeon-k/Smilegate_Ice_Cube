print("SandBoxUITest_Lua");

SandBoxUITest_Lua = {}

function SandBoxUITest_Lua.GetTable()
    local this = {}
    local GameObject = UnityEngine.GameObject
    local thisGameObject
    local thisLuaComponent
    local thisTransform

    local exitGameBtn = nil

    local logText = nil
    local dataLogText = nil

    local showUIBtn = nil
    local testFunctionBtn = nil
    local openConfigBtn = nil
    local openFriendBtn = nil
    local openChatBtn = nil
    local openHUDMenuBtn = nil
    local openLoadingBoxBtn = nil
    local closeLoadingBoxBtn = nil

    local testFunctionIndex = nil

    local isShowUI

    -- Awake
    function this.Awake(luaComponentInfo)
        print("SandBoxUITest_Lua Awake")
        
        thisGameObject = luaComponentInfo.TargetGameObject    
        thisTransform = luaComponentInfo.TargetTransform
        thisLuaComponent = luaComponentInfo.Owner   

        isShowUI = true
    end
    
    -- Start is called before the first frame update
    function this.Start()
        exitGameBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("ExitGame").UnityObject:GetComponent("Button")
        exitGameBtn.onClick:AddListener(this.ExitGame)

        logText = thisLuaComponent:GetUnityObjectPropertyValueByName("LogText").UnityObject:GetComponent("Text")
        dataLogText = thisLuaComponent:GetUnityObjectPropertyValueByName("DataLogText").UnityObject:GetComponent("Text")

        showUIBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("ShowUI").UnityObject:GetComponent("Button")
        showUIBtn.onClick:AddListener(this.ShowUI)

        testFunctionBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("TestFunction").UnityObject:GetComponent("Button")
        testFunctionBtn.onClick:AddListener(this.TestFunction)

        openConfigBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("OpenConfig").UnityObject:GetComponent("Button")
        openConfigBtn.onClick:AddListener(this.OpenConfigBtn)

        openFriendBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("OpenFriend").UnityObject:GetComponent("Button")
        openFriendBtn.onClick:AddListener(this.OpenFriendBtn)

        openChatBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("OpenChat").UnityObject:GetComponent("Button")
        openChatBtn.onClick:AddListener(this.OpenChatBtn)

        openHUDMenuBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("OpenHUDMenu").UnityObject:GetComponent("Button")
        openHUDMenuBtn.onClick:AddListener(this.OpenHUDMenuBtn)

        openLoadingBoxBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("OpenLoadingBox").UnityObject:GetComponent("Button")
        openLoadingBoxBtn.onClick:AddListener(this.OpenLoadingBoxBtn)

        closeLoadingBoxBtn = thisLuaComponent:GetUnityObjectPropertyValueByName("CloseLoadingBox").UnityObject:GetComponent("Button")
        closeLoadingBoxBtn.onClick:AddListener(this.CloseLoadingBoxBtn)

        testFunctionIndex = thisLuaComponent:GetUnityObjectPropertyValueByName("TestFunctionIndex").UnityObject:GetComponent("Dropdown")
    end
    
    function this.OnDestroy()
    end

    -- Update is called once per frame
    function this.Update()
    end

    function this.ShowUI()
        if isShowUI == true then 
            isShowUI = false
        else
            isShowUI = true
        end

        print("ShowUI")
        testFunctionBtn.gameObject:SetActive(isShowUI)
        openConfigBtn.gameObject:SetActive(isShowUI)
        openFriendBtn.gameObject:SetActive(isShowUI)
        openChatBtn.gameObject:SetActive(isShowUI)
        openHUDMenuBtn.gameObject:SetActive(isShowUI)
        openLoadingBoxBtn.gameObject:SetActive(isShowUI)
        closeLoadingBoxBtn.gameObject:SetActive(isShowUI)
        exitGameBtn.gameObject:SetActive(isShowUI)
        testFunctionIndex.gameObject:SetActive(isShowUI)
    end

    function this.TestFunction()
        if testFunctionIndex.value == 0 then 
            print("TestFunction1")
            USGFramework.Runtime.Contents.CommonAction.TestFunction1()
        elseif testFunctionIndex.value == 1  then
            print("TestFunction2")
            USGFramework.Runtime.Contents.CommonAction.TestFunction2()
        elseif testFunctionIndex.value == 2  then
            print("TestFunction3")
            USGFramework.Runtime.Contents.CommonAction.TestFunction3()
        elseif testFunctionIndex.value == 3  then
            print("TestFunction4")
            USGFramework.Runtime.Contents.CommonAction.TestFunction4()
        elseif testFunctionIndex.value == 4  then
            print("TestFunction5")
            USGFramework.Runtime.Contents.CommonAction.TestFunction5()
        elseif testFunctionIndex.value == 5  then
            print("TestFunction6")
            USGFramework.Runtime.Contents.CommonAction.TestFunction6()
        elseif testFunctionIndex.value == 6  then
            print("TestFunction7")
            USGFramework.Runtime.Contents.CommonAction.TestFunction7()
        elseif testFunctionIndex.value == 7  then
            print("TestFunction8")
            USGFramework.Runtime.Contents.CommonAction.TestFunction8()
        elseif testFunctionIndex.value == 8  then
            print("TestFunction9")
            USGFramework.Runtime.Contents.CommonAction.TestFunction9()
        elseif testFunctionIndex.value == 9  then
            print("TestFunction10")
            USGFramework.Runtime.Contents.CommonAction.TestFunction10()
        else
            print("????")
        end
    end

    function this.ExitGame()
        print("ExitGame")
        USGFramework.Runtime.Contents.CommonAction.ExitGame()
    end

    function this.OpenConfigBtn()
        print("OpenConfigBtn")
        USGFramework.Runtime.Contents.CommonAction.OpenConfig()
    end

    function this.OpenFriendBtn()
        print("OpenFriendBtn")
        USGFramework.Runtime.Contents.CommonAction.OpenFriend()
    end

    function this.OpenChatBtn()
        print("OpenChatBtn")
        USGFramework.Runtime.Contents.CommonAction.OpenChat()
    end

    function this.OpenHUDMenuBtn()
        print("OpenHUDMenuBtn")
        USGFramework.Runtime.Contents.CommonAction.OpenHUDMenu()
    end

    function this.OpenLoadingBoxBtn()
        print("OpenLoadingBoxBtn")
        local keystr = "TestKey"
        USGFramework.Runtime.Contents.CommonAction.OpenLoadingBox(keystr)
    end

    function this.CloseLoadingBoxBtn()
        print("CloseLoadingBoxBtn")
        local keystr = "TestKey"
        USGFramework.Runtime.Contents.CommonAction.CloseLoadingBox(keystr)
    end

    return this
end