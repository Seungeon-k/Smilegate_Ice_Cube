local this = __CREATOR__.new()

local scriptObject
local root = nil
local colliders = {} 

this.IsVisibleOnStart = __EX_VARIABLE__.bool(true)
this.Duration = __EX_VARIABLE__.float(2.0)

this.CurrentVisible = __EX_VARIABLE__.bool(false)

this.OnShow = __EX_VARIABLE__.event()
this.OnShowComplete = __EX_VARIABLE__.event()

this.OnHide = __EX_VARIABLE__.event()
this.OnHideComplete = __EX_VARIABLE__.event()

function this.OnAwake()
    scriptObject = this.scriptObject
    root = scriptObject.parent.parent
    colliders = root:GetComponentsInChildren("Collider")
end

function this.OnStart()    
    if this.IsVisibleOnStart then
        this.Show()
    else
        this.CurrentVisible = false
        this.SetCollidersEnabled(false)    
    end
end

function this.SetCollidersEnabled(isEnabled)
    for i = 1, #colliders do
        if colliders[i] then
            colliders[i].enabled = isEnabled
        end
    end
end

local function ShowSequenceAsync()
    VFramework.WaitForSeconds(this.Duration)
    if this.OnShowComplete ~= nil then        
        this.OnShowComplete:Call()
    end
end

local function HideSequenceAsync()
    VFramework.WaitForSeconds(this.Duration)
    if this.OnHideComplete ~= nil then
        this.OnHideComplete:Call()
    end
end

__EX_FUNCTION__(this)
function this.Show()    
    if this.OnShow ~= nil then               
        this.OnShow:Call()
    end

    this.CurrentVisible = true
    this.SetCollidersEnabled(true)       
    scriptObject:AsyncCall(ShowSequenceAsync)    
end

__EX_FUNCTION__(this)
function this.Hide()    
    if this.OnHide ~= nil then
        this.OnHide:Call()
    end
    this.CurrentVisible = false
    this.SetCollidersEnabled(false)    
    
    scriptObject:AsyncCall(HideSequenceAsync)
end