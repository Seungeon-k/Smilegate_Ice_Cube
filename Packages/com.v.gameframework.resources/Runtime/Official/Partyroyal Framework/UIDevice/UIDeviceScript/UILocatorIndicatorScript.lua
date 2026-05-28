local this = __CREATOR__.new()

this.IndicatorTarget  = __EX_VARIABLE__.vobject()
this.IsVisible = __EX_VARIABLE__.bool(true)


this.uiRoot = __EX_VARIABLE__.vobject()
this.pointLeft = __EX_VARIABLE__.vobject()
this.pointRight = __EX_VARIABLE__.vobject()
this.pointUp = __EX_VARIABLE__.vobject()
this.pointDown = __EX_VARIABLE__.vobject()

local serviceApi
local scriptObject
local uiService
local soundService
local cameraService

local targetObject = nil
local gameCamera
local cameraComp
local edgePadding = 36.0

function this.SetTarget(target)
	targetObject = target
end

function this.OnStart()
	serviceApi = this.serviceApi
	scriptObject = this.scriptObject

	uiService = serviceApi.uiService
	soundService = serviceApi.soundService
	cameraService = serviceApi.cameraService

	gameCamera = cameraService:GetGameCamera()
	_, cameraComp = gameCamera:GetComponentByType(typeof(VFramework.Camera))

	this.uiRoot:SetActive(false)
	edgePadding = this.pointLeft.transform.rect.height

	if this.IndicatorTarget then
		this.SetTarget(this.IndicatorTarget)
	end
end

local function deactivatePoints()
	this.pointLeft:SetActive(false)
	this.pointRight:SetActive(false)
	this.pointUp:SetActive(false)
	this.pointDown:SetActive(false)
end

local eps = 1e-3
local function edgeViewport(vpx, vpy, vpz)
    -- 화면 중심 기준 방향
    local dx = vpx - 0.5
    local dy = vpy - 0.5

    -- 뒤에 있으면 방향만 뒤집음
    if vpz < 0 then
        dx = -dx
        dy = -dy
    end

    local ax = math.abs(dx)
    local ay = math.abs(dy)
    local m = math.max(ax, ay)

    -- ✅ 정면/정확한 뒤쪽처럼 dx=dy=0이면 "항상 위쪽 edge"로 보내기(규칙)
    if m < eps then
        return 0.5, 1.0
    end

    local t = 0.5 / m
    return 0.5 + dx * t, 0.5 + dy * t
end


local function displayPoint(ex, ey)
	deactivatePoints()	

	if ey >= 1.0 - eps then
        this.pointUp:SetActive(true)
    elseif ey <= eps then
        this.pointDown:SetActive(true)
    elseif ex <= eps then
        this.pointLeft:SetActive(true)
    elseif ex >= 1.0 - eps then
        this.pointRight:SetActive(true)
    end
end

local function displayIcon(ex, ey)
	local canvasRect = uiService.canvas.canvasRect
	if canvasRect.width <= 0 or canvasRect.height <= 0 then
		this.uiRoot:SetActive(false)
		return
	end

	local w = canvasRect.width
    local h = canvasRect.height

	local halfW = canvasRect.width  * 0.5
    local halfH = canvasRect.height * 0.5

	local x = (ex - 0.5) * w
	local y = (ey - 0.5) * h

	local iconRect = this.uiRoot.transform
	local padX = (iconRect.rect.width + edgePadding) * 0.5
	local padY = (iconRect.rect.height + edgePadding) * 0.5

	x = Mathf.Clamp(x, -halfW + padX, halfW - padX)
	y = Mathf.Clamp(y, -halfH + padY, halfH - padY)

	this.uiRoot.transform.anchoredPosition = Vector2(x, y)
end

function this.OnLateUpdate()
	if targetObject == nil then return end
	if not this.IsVisible then
		this.uiRoot:SetActive(false)
		return
	end

	local vp = cameraComp:WorldToViewportPoint(targetObject.transform.position)

	local onScreen = (vp.z > 0) and (vp.x >= 0 and vp.x <= 1) and (vp.y >= 0 and vp.y <= 1)
	if onScreen then
		this.uiRoot:SetActive(false)
		return
	end

	--print('late update : ', vp.x, vp.y)

	this.uiRoot:SetActive(true)	

	local ex, ey = edgeViewport(vp.x, vp.y, vp.z)
	
	displayPoint(ex, ey)
	displayIcon(ex, ey)	

end

__EX_FUNCTION__(this)
function this.Show()
	this.IsVisible = true
end

__EX_FUNCTION__(this)
function this.Hide()
	this.IsVisible = false
end

