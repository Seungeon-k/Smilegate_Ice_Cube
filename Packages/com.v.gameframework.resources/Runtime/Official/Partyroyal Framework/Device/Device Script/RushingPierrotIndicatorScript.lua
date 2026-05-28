local this = __CREATOR__.new()

this.indicatorTarget = __EX_VARIABLE__.vobject()
this.indicatorAsset = __EX_VARIABLE__.vobject()

local serviceApi
local scriptObject
local uiService

local indicator
local indicatorScript

function this.OnStart()
    serviceApi = this.serviceApi
    scriptObject = this.scriptObject
    uiService = serviceApi.uiService
end

__EX_FUNCTION__(this)
function this.CreateIndicator()
    indicator = uiService:Instantiate(this.indicatorAsset)

    indicatorScript = indicator.Script:GetLua()
    indicatorScript.SetTarget(this.indicatorTarget)
end

__EX_FUNCTION__(this)
function this.DestroyIndicator()
    if indicator then
        indicator:Destroy()
    end
end

__EX_FUNCTION__(this)
function this.ShowIndicator()
    if indicatorScript then
        indicatorScript.Show()
    end
end

__EX_FUNCTION__(this)
function this.HideIndicator()
    if indicatorScript then
        indicatorScript.Hide()
    end
end

