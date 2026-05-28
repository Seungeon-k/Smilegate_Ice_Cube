
    local this = __CREATOR__.new()

	local RESULT_SUCCESS = 1
	local DATA_SIZE = 25
	local PAGE_SIZE = 5
	local PAGE_ITEM_SIZE = 5
	local DATA_BLOCK_SIZE = PAGE_SIZE * PAGE_ITEM_SIZE;
	
    local CLOSE_ANIM_KEY = 'Popup_Close_03'

    this.animator  = __EX_VARIABLE__.component.animator()
	
	this.titleText  = __EX_VARIABLE__.component.text()
	this.descriptionText  = __EX_VARIABLE__.component.text()
	
	this.seasonText  = __EX_VARIABLE__.component.text()
	this.prevSeasonEnable  = __EX_VARIABLE__.vobject()
	this.prevSeasonDisable  = __EX_VARIABLE__.vobject()
	this.nextSeasonEnable  = __EX_VARIABLE__.vobject()
	this.nextSeasonDisable  = __EX_VARIABLE__.vobject()
	
	this.prevPageEnable  = __EX_VARIABLE__.vobject()
	this.prevPageDisable  = __EX_VARIABLE__.vobject()
	this.nextPageEnable  = __EX_VARIABLE__.vobject()
	this.nextPageDisable  = __EX_VARIABLE__.vobject()
	this.pageOnIcons = __EX_VARIABLE__.list(__EX_VARIABLE__.component.text())
	this.pageOffIcons = __EX_VARIABLE__.list(__EX_VARIABLE__.component.text())
	
	this.rankText  = __EX_VARIABLE__.component.text()
	this.nameText  = __EX_VARIABLE__.component.text()
	
	this.mainScore  = __EX_VARIABLE__.vobject()
	this.subScore1  = __EX_VARIABLE__.vobject()
	this.subScore2  = __EX_VARIABLE__.vobject()
	
	this.mainScoreText  = __EX_VARIABLE__.component.text()
	this.subScore1Text  = __EX_VARIABLE__.component.text()
	this.subScore2Text  = __EX_VARIABLE__.component.text()
	
	this.myRankItem = __EX_VARIABLE__.vobject()
	this.rankItems = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())

    this.info = nil
	this.data = nil
	
	this.myRankItemScript = nil
	this.rankItemScripts = nil
	
	this.seasonIndex = 0
	
	this.dataIndex = 1
    this.dataCount = 0
    this.pageIndex = 1
    this.pageCount = 0
	
	local isInputLock = false

    function this.OnStart()
		this.InitItems()
		
		this.serviceApi.leaderboardService:GetInfo(this.OnGetInfo)

		isInputLock = this.serviceApi.inputService.isInputLock
        this.serviceApi.inputService.isInputLock = true
    end
	
	function this.InitItems()
		this.myRankItemScript = this.myRankItem:Find('Script'):GetLua()
		
		this.rankItemScripts = {}
		for i, item in ipairs(this.rankItems) do
			table.insert(this.rankItemScripts, item:Find('Script'):GetLua())
			item:SetActive(false)
		end
	end
	
	function this.OnGetInfo(code, message, info)
        if code ~= RESULT_SUCCESS then
            return
        end

        this.info = info
		
		this.titleText.text = info.title or ''
		this.descriptionText.text = info.description or ''
		
		this.SetSeasonInfo()
		this.SetScoreInfo()
		
		this.serviceApi.leaderboardService:GetData(this.seasonIndex, this.dataIndex, DATA_SIZE, this.OnGetData)
    end
	
	function this.SetSeasonInfo()
		local info = this.info
		this.seasonText.text = info.season.noSeason and '' or info.season.titles[this.seasonIndex]
		
		local hasPrevSeason = not info.season.noSeason and this.seasonIndex > -3
		this.prevSeasonEnable:SetActive(hasPrevSeason)
		this.prevSeasonDisable:SetActive(not hasPrevSeason)
		
		local hasNextSeason = not info.season.noSeason and this.seasonIndex < 0
		this.nextSeasonEnable:SetActive(hasNextSeason)
		this.nextSeasonDisable:SetActive(not hasNextSeason)
	end
	
	function this.SetScoreInfo()
		local info = this.info
		this.rankText.text = 'Rank'
		this.nameText.text = 'Name'
		
		this.mainScoreText.text = info.scores[1].name or ''
		
		if #info.scores > 1 then
			this.subScore1:SetActive(true)
			this.subScore1Text.text = info.scores[2].name or ''
		else 
			this.subScore1:SetActive(false)
		end
		
		if #info.scores > 2 then
			this.subScore2:SetActive(true)
			this.subScore2Text.text = info.scores[3].name or ''
		else 
			this.subScore2:SetActive(false)
		end
		
		this.myRankItemScript.SetRankItem(info, nil)
	end
	
	local function HasNextData()
		return this.dataIndex < this.dataCount
	end
	
	local function HasPrevData()
		return this.dataIndex > 1
	end
	
	local function HasNextPage()
		return this.pageIndex < this.pageCount
	end
	
	local function HasPrevPage()
		return this.pageIndex > 1
	end
	
	function this.OnGetData(code, message, data)
		if code ~= RESULT_SUCCESS then
            return
        end
		
		this.data = data
		
		this.SetSeasonInfo()
		this.SetPageData()
		this.SetRankItemData()
	end
	
	function this.SetPageData()
		local data = this.data
		this.dataCount = math.floor((data.totalCount - 1) / DATA_BLOCK_SIZE + 1)

		if HasNextData() then
			this.pageCount = PAGE_ITEM_SIZE;
		else 
			local lastRankingCount = data.totalCount % DATA_BLOCK_SIZE
			this.pageCount = math.floor((lastRankingCount - 1) / PAGE_ITEM_SIZE + 1)
		end

		local hasPrevPage = HasPrevData() or HasPrevPage()
		local hasNextPage = HasNextData() or HasNextPage()
		this.prevPageEnable:SetActive(hasPrevPage)
		this.prevPageDisable:SetActive(not hasPrevPage)
		this.nextPageEnable:SetActive(hasNextPage)
		this.nextPageDisable:SetActive(not hasNextPage)
		
		for i = 1, PAGE_SIZE do
			local pageNumber = math.floor((this.dataIndex - 1) * PAGE_SIZE + i)
			this.pageOnIcons[i].text = tostring(pageNumber)
			this.pageOffIcons[i].text = tostring(pageNumber)
			this.pageOnIcons[i].vObject:SetActive(i == this.pageIndex)
			this.pageOffIcons[i].vObject:SetActive(i ~= this.pageIndex)
		end
	end
	
	function this.SetRankItemData()
		local data = this.data
		for i = 1, PAGE_ITEM_SIZE do
			local itemScript = this.rankItemScripts[i]
			local index = (this.pageIndex - 1) * PAGE_ITEM_SIZE + i
			if index <= #data.list then
				itemScript.scriptObject.parent:SetActive(true)
				itemScript.SetRankItem(this.info, data.list[index])
			else
				itemScript.scriptObject.parent:SetActive(false)
			end
		end

		this.myRankItemScript.SetRankItem(this.info, data.userData)
	end

    __EX_FUNCTION__(this)
    function this.CloseUI()
        this.serviceApi.inputService.isInputLock = isInputLock
		
        this.animator:Play(CLOSE_ANIM_KEY)

        this.scriptObject:AsyncCall(function() 
            VFramework.WaitForSeconds(0.3)
            this.scriptObject.parent:Destroy()
        end)
    end
	
	__EX_FUNCTION__(this)
	function this.OnSeasonPrev()
		if this.seasonIndex <= -3 then
			return
		end
		
		this.seasonIndex = this.seasonIndex - 1
		this.dataIndex = 1
		this.pageIndex = 1
		
		this.serviceApi.leaderboardService:GetData(this.seasonIndex, this.dataIndex, DATA_SIZE, this.OnGetData)
	end
	
	__EX_FUNCTION__(this)
    function this.OnSeasonNext()
		if this.seasonIndex >= 0 then
			return
		end
		
		this.seasonIndex = this.seasonIndex + 1
		this.dataIndex = 1
		this.pageIndex = 1
		
		this.serviceApi.leaderboardService:GetData(this.seasonIndex, this.dataIndex, DATA_SIZE, this.OnGetData)
    end
	
	__EX_FUNCTION__(this)
    function this.OnPagePrev()
		if HasPrevPage() then
			this.pageIndex = this.pageIndex - 1
			this.SetPageData()
			this.SetRankItemData()
		elseif HasPrevData() then
			this.dataIndex = this.dataIndex - 1
			this.pageIndex = 1
			this.serviceApi.leaderboardService:GetData(this.seasonIndex, this.dataIndex, DATA_SIZE, this.OnGetData)
		end
    end
	
	__EX_FUNCTION__(this)
    function this.OnPageNext()
		if HasNextPage() then
			this.pageIndex = this.pageIndex + 1
			this.SetPageData()
			this.SetRankItemData()
		elseif HasNextData() then
			this.dataIndex = this.dataIndex + 1
			this.pageIndex = 1
			this.serviceApi.leaderboardService:GetData(this.seasonIndex, this.dataIndex, DATA_SIZE, this.OnGetData)
		end
    end
