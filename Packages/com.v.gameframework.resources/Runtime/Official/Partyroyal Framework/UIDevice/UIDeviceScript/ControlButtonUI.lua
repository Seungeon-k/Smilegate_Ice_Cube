local this = __CREATOR__.new()

local serviceApi
local script

this.uiRoot = __EX_VARIABLE__.vobject()

this.jumpButton = __EX_VARIABLE__.vobject()
this.dashButton = __EX_VARIABLE__.vobject()

this.itemButtons = __EX_VARIABLE__.list(__EX_VARIABLE__.vobject())

local actionButtons = {}


function this.OnStart()
	serviceApi = this.serviceApi
	script = this.scriptObject

	
	script:Log("Start")
	
	this.InitActionButtons()
end


function this.OnUpdate(deltaTime)

	
	for i,v in ipairs(actionButtons) do 
		if v.active == true then
			if v.currentCoolTime > 0 then
				v.currentCoolTime = v.currentCoolTime - deltaTime
				if v.currentCoolTime < 0 then
					 v.currentCoolTime = 0
					 v.fxAction:SetActive(true)					 
				end
				this.UpdateCooltime(v)
			end
		end
	end

end

__EX_FUNCTION__(this)
function this.OnGameFinished()
	this.uiRoot:SetActive(false)
end

__EX_FUNCTION__(this)
function this.OnGameFinished()
	this.uiRoot:SetActive(false)
end

__EX_FUNCTION__(this)
function this.ShowControlUI()
	this.uiRoot:SetActive(true)
end

__EX_FUNCTION__(this)
function this.HideControlUI()
	this.uiRoot:SetActive(false)
end

__EX_FUNCTION__(this)
function this.ShowByInputControl()
	this.uiRoot:SetActive(true)
end

__EX_FUNCTION__(this)
function this.HideByInputControl()
	this.uiRoot:SetActive(false)
end

local function LoadActionButton(root)
	local actionButton = {}
	
	actionButton['root'] = root
	actionButton['icon'] = root:Find("Icon")
	actionButton['countInfo'] = root:Find("CountInfo")
	actionButton['coolTimeGO'] = root:Find("CoolTime")
	actionButton['stack'] = root:Find("Stack")
	actionButton['fxAction'] = root:Find("@FX_Action")	

	
	actionButton['inputBinding'] = actionButton.root:GetComponent('InputBindingHandler')
	actionButton['iconImage'] = actionButton.icon:GetComponent('Image')
	actionButton['countInfoText']= actionButton.countInfo:Find("Text_Num"):GetComponent('TextMeshProUGUI')
	actionButton['countInfoAnimator'] = actionButton.countInfo:GetComponent('Animator')
	actionButton['coolTimeSlider'] = actionButton.coolTimeGO:GetComponent('Slider')
	actionButton['stackSlider'] = actionButton.stack:GetComponent('Slider')
	actionButton['fxActionPS'] = actionButton.fxAction:GetComponent('ParticleSystem')
	
	actionButton['active'] = false
	actionButton['count'] = 0
	actionButton['infinite'] = false
	actionButton['coolTime'] = 0
	actionButton['currentCoolTime'] = 0
	actionButton['stackCooltime'] = 0
	actionButton['currentStackCooltime'] = 0
	
	return actionButton
end

function this.UpdateCooltime(actionButton)
	if actionButton.active == false then return end

	if actionButton.coolTime > 0 and actionButton.currentCoolTime > 0 then
		if actionButton.currentCoolTime <= 0 then
			actionButton.coolTimeGO:SetActive(false)
			actionButton.currentCoolTime = 0
			actionButton.inputBinding.inputEnabled = true
		else
			actionButton.coolTimeGO:SetActive(true)
			actionButton.coolTimeSlider.value = actionButton.currentCoolTime / actionButton.coolTime
			actionButton.inputBinding.inputEnabled = false
		end
	else
		actionButton.coolTimeGO:SetActive(false)
		actionButton.inputBinding.inputEnabled = true
	end

		
	if actionButton.stackCooltime > 0 and actionButton.currentStackCooltime > 0 then
		if actionButton.currentStackCooltime <= 0 then
			actionButton.stack:SetActive(false)
			actionButton.currentStackCooltime = 0
		else
			actionButton.stack:SetActive(true)
			actionButton.stackSlider.value = (actionButton.stackCooltime - actionButton.currentStackCooltime) / actionButton.stackCooltime
		end
	else
		actionButton.stack:SetActive(false)
	end

end

local function UpdateActionButtonUI(actionButton)
	if not actionButton.active then 
		actionButton.root:SetActive(false)
		return
	end
	
	actionButton.root:SetActive(true)
	
	if actionButton.sprite then
		actionButton.icon:SetActive(true)
		actionButton.iconImage.sprite = actionButton.sprite
	else 
		actionButton.icon:SetActive(false)
	end
	
	if actionButton.count then
		actionButton.countInfo:SetActive(true)

		if actionButton.infinite ~= nil and actionButton.infinite == true then
			actionButton.countInfoText.text = '∞'
		else
			actionButton.countInfoText.text = tostring(actionButton.count)
		end
		
	else 
		actionButton.countInfo:SetActive(false)
	end
	
	if actionButton.coolTime > 0 and actionButton.currentCoolTime > 0 then
		if actionButton.currentCoolTime <= 0 then
			actionButton.coolTimeGO:SetActive(false)
			actionButton.currentCoolTime = 0
			actionButton.inputBinding.inputEnabled = true
		else
			actionButton.coolTimeGO:SetActive(true)
			actionButton.inputBinding.inputEnabled = false
			actionButton.coolTimeSlider.value = actionButton.currentCoolTime / actionButton.coolTime
		end
	else
		actionButton.coolTimeGO:SetActive(false)
		actionButton.inputBinding.inputEnabled = true
	end
	
	if actionButton.stackCooltime > 0 and actionButton.currentStackCooltime > 0 then
		if actionButton.currentStackCooltime <= 0 then
			actionButton.stack:SetActive(false)
			actionButton.currentStackCooltime = 0
		else
			actionButton.stack:SetActive(true)
			actionButton.stackSlider.value = (actionButton.stackCooltime - actionButton.currentStackCooltime) / actionButton.stackCooltime
		end
	else
		actionButton.stack:SetActive(false)
	end
end

local function UpdateActionCoolTime(actionButton)
	UpdateActionButtonUI(actionButton)
end

function this.InitActionButtons()

	for _, itemButton in ipairs(this.itemButtons) do
		table.insert(actionButtons, LoadActionButton(itemButton))
	end

end

function this.EnableActionButton(buttonIndex, sprite, count, infinite, coolTime)

	--script:Log("EnableActionButton " .. tostring(count))
	local actionButton = actionButtons[buttonIndex]
	if actionButton.active == false then
		actionButton.currentCoolTime = 0
	end

	if count > 0 then
		actionButton.countInfoAnimator:Play('Skill_Count', 0, 0)
		actionButton.fxActionPS:Play()
	end

	actionButton.active = true
	actionButton.sprite = sprite
	actionButton.infinite = infinite
	actionButton.count = count
	actionButton.coolTime = coolTime
	UpdateActionButtonUI(actionButton)
	UpdateActionCoolTime(actionButton)
end



function this.DisableActionButton(buttonIndex)
	local actionButton = actionButtons[buttonIndex]
	actionButton.active = false
	actionButton.coolTime = 0
	actionButton.currentCoolTime = 0
	UpdateActionButtonUI(actionButton)
	UpdateActionCoolTime(actionButton)
end

function this.SetCount(buttonIndex, count)
	local actionButton = actionButtons[buttonIndex]
	actionButton.count = count
	actionButton.fxAction:SetActive(false)	
	UpdateActionButtonUI(actionButton)
end

function this.SetCoolTimeOnActionButton(buttonIndex, coolTime, currentCoolTime)
	local actionButton = actionButtons[buttonIndex]
	actionButton.coolTime = coolTime
	actionButton.currentCoolTime = currentCoolTime
	UpdateActionCoolTime(actionButton)
end

function this.SetStackCoolTimeOnActionButton(buttonIndex, stackCooltime, currentStackCooltime)
	local actionButton = actionButtons[buttonIndex]
	actionButton.stackCooltime = stackCooltime
	actionButton.currentStackCooltime = currentStackCooltime
	UpdateActionCoolTime(actionButton)
end

function this.IsActionButtonVaild(buttonIndex)
	local actionButton = actionButtons[buttonIndex]

	if actionButton.active == false or actionButton.currentCoolTime > 0  then
		return false
	end

	return true
end
