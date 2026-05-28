local this = __CREATOR__.new()

local serviceApi
local script

local canvas
local root
local animator
local bgRectTransform
local bgRectTransformRect
local handleRectTransform
local directionEffect
local directionEffectImage

local inputBindingHandler

local startPosition
local cachedMovement

local ANI_OPEN = 'open'
local ANI_CLOSE = 'close'

function this.OnStart()
	serviceApi = this.serviceApi
	script = this.scriptObject
	
	script:Log("Start")
	
	local joystick = script.parent
	if joystick then
		if joystick.OnTouchDown then joystick.OnTouchDown:AddListener(this.OnTouchDown) end
		if joystick.OnTouch then joystick.OnTouch:AddListener(this.OnTouch) end
		if joystick.OnTouchUp then joystick.OnTouchUp:AddListener(this.OnTouchUp) end
	end

	canvas = serviceApi.uiService.canvas
	root = joystick:Find("Area")
	animator = joystick:Find("Area/Animation"):GetComponent('Animator')
	
	bgRectTransform = joystick:Find("Area/Animation/BG_Dark").transform
	bgRectTransformRect = bgRectTransform.rect
	directionEffect = joystick:Find("Area/Animation/@Eff_Direction").transform
	directionEffectImage = directionEffect:GetComponent('Image')
	handleRectTransform = joystick:Find("Area/Animation/Handle").transform
	
	inputBindingHandler = joystick:GetComponent('InputBindingHandler')
	
	animator:Play(ANI_CLOSE, 0, 0)
	
	startPosition = Vector2.zero
	cachedMovement = Vector2.zero
end

__EX_FUNCTION__(this)
function this.OnGameFinished()
	serviceApi.inputService.isInputLock = true
	root:SetActive(false)
end

function this.OnTouchDown(value)
	startPosition = value
	animator:Play(ANI_OPEN, 0, 0)
end

function this.OnTouch(value)
	local positionGap = (value - startPosition) / canvas.scaleFactor
	local halfSize = bgRectTransformRect.width / 2
	local magnitude = positionGap.magnitude
	local ratio = Mathf.InverseLerp(0, halfSize, magnitude)
	ratio = Mathf.Clamp01(ratio)
	
	local color = directionEffectImage.color
	color.a = Mathf.Clamp01(ratio * 2)
	directionEffectImage.color = color
	
	local directionVector = Vector2(positionGap.x, positionGap.y).normalized
	local angle = Vector2.Angle(Vector2.up, directionVector)
	if positionGap.x > 0 then
		angle = angle * -1
	end
	
	directionEffect.rotation = Quaternion.Euler(Vector3(0, 0, angle))
	
	local newPosition = positionGap / magnitude * ratio * halfSize
	handleRectTransform.anchoredPosition = newPosition
	
	if ratio < 0.15 then
		if cachedMovement.x ~= 0 or cachedMovement.y ~= 0 then
			cachedMovement.x = 0
			cachedMovement.y = 0
			this.InvokeInputBinding()
		end
		return
	end
	
	cachedMovement.x = handleRectTransform.anchoredPosition.x / (bgRectTransformRect.width / 2)
	cachedMovement.y = handleRectTransform.anchoredPosition.y / (bgRectTransformRect.height / 2)
	
	this.InvokeInputBinding()
end

function this.OnTouchUp(value)
	this.ResetPosition()
	animator:Play(ANI_CLOSE, 0, 0)
end

function this.ResetPosition()
	handleRectTransform.localPosition = Vector3.zero
	
	cachedMovement.x = 0
	cachedMovement.y = 0
	
	this.InvokeInputBinding()
end

function this.InvokeInputBinding()
	if inputBindingHandler then
		inputBindingHandler:SetVector2Value(cachedMovement)
	end
end

__EX_FUNCTION__(this)
function this.ShowControlUI()
	root:SetActive(true)
	serviceApi.inputService.isInputLock = false
end

__EX_FUNCTION__(this)
function this.HideControlUI()
	root:SetActive(false)
	serviceApi.inputService.isInputLock = true
end

__EX_FUNCTION__(this)
function this.ShowByInputControl()
	root:SetActive(true)
end

__EX_FUNCTION__(this)
function this.HideByInputControl()
	root:SetActive(false)
end
