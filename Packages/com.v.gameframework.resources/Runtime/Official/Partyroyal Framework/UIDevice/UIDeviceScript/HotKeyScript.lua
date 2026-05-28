local this = __CREATOR__.new()

local serviceApi
local scriptObject
local inputService

local bindHandler = nil

this.DisplayOnStart = __EX_VARIABLE__.bool(true)

this.Key = _VCOMPONENT_.text()

this.Enter = __EX_VARIABLE__.vobject()
this.Shift = __EX_VARIABLE__.vobject()
this.Tab = __EX_VARIABLE__.vobject()
this.Space = __EX_VARIABLE__.vobject()
this.LeftArrow = __EX_VARIABLE__.vobject()
this.RightArrow = __EX_VARIABLE__.vobject()
this.UpArrow = __EX_VARIABLE__.vobject()
this.DownArrow = __EX_VARIABLE__.vobject()

this.LMouse = __EX_VARIABLE__.vobject()
this.RMouse = __EX_VARIABLE__.vobject()
this.WheelMouse = __EX_VARIABLE__.vobject()



local hotKeys = {}
local keyTextMap = {
	Semicolon = ';',
	Equals = '=',
	Comma = ',',
	Period = '.',
	Slash = '/',
	Minus = '-',
	LeftBracket = '[',
	RightBracket = ']',
	Escape = 'Esc',
	LeftShift = 'L Shift',
	RightShift = 'R Shift',
	LeftControl = 'L Ctrl',
	RightControl = 'R Ctrl',
	LeftAlt = 'L Alt',
	RightAlt = 'R Alt'
}

local enableShowHotKey = true

local function hideAll()
	for _, v in pairs(hotKeys) do
		v:SetActive(false)
	end
end

function this.OnAwake()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
	inputService = serviceApi.inputService

	hotKeys['Key'] = this.Key.vObject.parent
	hotKeys['Enter'] = this.Enter
	hotKeys['Shift'] = this.Shift
	hotKeys['Tab'] = this.Tab
	hotKeys['Space'] = this.Space
	hotKeys['LeftArrow'] = this.LeftArrow
	hotKeys['RightArrow'] = this.RightArrow
	hotKeys['UpArrow'] = this.UpArrow
	hotKeys['DownArrow'] = this.DownArrow
	hotKeys['Mouse Button 1'] = this.LMouse
	hotKeys['Mouse Button 2'] = this.RMouse
	hotKeys['Mouse Button 3'] = this.WheelMouse

	hideAll()
end

local function displayKeyText(keyCode)
	if enableShowHotKey == false then
		this.Key.vObject.parent:SetActive(false)
	else
		this.Key.vObject.parent:SetActive(true)
	end

	if keyTextMap[keyCode] == nil then	
		this.Key.text = keyCode
	else
		this.Key.text = keyTextMap[keyCode]
	end
end

local function displayKeyCode(keyCode)	
	if hotKeys[keyCode] == nil then
		displayKeyText(keyCode)
	else
		hotKeys[keyCode]:SetActive(true)
	end
end

local function displayKeyTable(inputs)
	if inputs == nil or #inputs <= 0 then return end
	
	if #inputs > 1 then
		local keyText = table.concat(inputs, ", ")

		displayKeyText(keyText)
	else
		local code = inputs[1]
		displayKeyCode(code)
	end
end

local function canDisplayDevice(inputType)
	if inputService.KeyboardEnabled and inputType == VFramework.InputDeviceType.Keyboard then
		return true
	end
	if inputService.MouseEnabled and inputType == VFramework.InputDeviceType.Mouse then
		return true
	end

	return true
end

local function displayInputFromHandler(handler)
	local inputs = handler:GetInputs()
	for _, v in ipairs(inputs) do
		if canDisplayDevice(v.deviceType) then
			displayKeyCode(v.key)
			break
		end
	end
end

function this.OnStart()
	
	local target = scriptObject.parent.parent
	if target == nil then return end
	
	local ok, handler = target:GetComponentByType(typeof(VFramework.InputBindingHandler))
	if ok then

		bindHandler = handler

		if not this.DisplayOnStart then return end

		displayInputFromHandler(bindHandler)
	end

	if enableShowHotKey == false then
        hideAll()
    end
end

function this.EnableHotKeyByPlatform(enable)
    -- modify only pc platform
    enableShowHotKey = enable	
end

local _actionName = ''

local function displayKeyCodeFromAction(actionName)
	local inputKeys = inputService:GetInputKeysInAction(_actionName)
	displayKeyTable(inputKeys)
end

__EX_FUNCTION__(this, __EX_VARIABLE__.string())
function this.SetActionName(actionName)
	_actionName = actionName
end

__EX_FUNCTION__(this)
function this.Show()
	if bindHandler ~= nil then
		displayInputFromHandler(bindHandler)
	else
		hideAll()
		displayKeyCodeFromAction(_actionName)
	end
end

__EX_FUNCTION__(this)
function this.Hide()
	hideAll()
end

__EX_FUNCTION__(this, __EX_VARIABLE__.string())
function this.DisplayKeyCode(keyCode)
	hideAll()
	displayKeyCode(keyCode)
end

__EX_FUNCTION__(this, __EX_VARIABLE__.string())
function this.DisplayKeyCodeFromAction(actionName)
	hideAll()
	displayKeyCodeFromAction(actionName)
end


