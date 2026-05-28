
    local this = __CREATOR__.new()

    local CLOSE_ANIM_KEY = 'Popup_Close_03'

    this.title  = __EX_VARIABLE__.component.text()
    this.message  = __EX_VARIABLE__.component.text()
    this.animator  = __EX_VARIABLE__.component.animator()
    this.confirmButton  = __EX_VARIABLE__.vobject()
    this.confirmTitle  = __EX_VARIABLE__.component.text()
    this.cancelButton = __EX_VARIABLE__.vobject()
    this.cancelTitle  = __EX_VARIABLE__.component.text()

    this.confirmCallback = nil
    this.cancelCallback = nil

    function this.OnStart()
        
    end
    
    function this.SetMessages(title, message)
        this.title.text = title or ''
        this.message.text = message or ''
    end

    function this.SetButtons(confirmTitle, cancelTitle, confirmCallback, cancelCallback)
        if confirmTitle then
            this.confirmButton:SetActive(true)
            this.confirmTitle.text = confirmTitle or ''
            this.confirmCallback = confirmCallback
        else 
            this.confirmButton:SetActive(false)
        end

        if cancelTitle then
            this.cancelButton:SetActive(true)
            this.cancelTitle.text = cancelTitle or ''
            this.cancelCallback = cancelCallback
        else 
            this.cancelButton:SetActive(false)
        end
    end

    function this.CloseUI()
        this.animator:Play(CLOSE_ANIM_KEY)

        this.scriptObject:AsyncCall(function() 
            VFramework.WaitForSeconds(0.3)
            this.scriptObject.parent:Destroy()
        end)
    end

    __EX_FUNCTION__(this)
    function this.OnConfirm()
        if this.confirmCallback then
            this.confirmCallback()
        end
        this.CloseUI()
    end

    __EX_FUNCTION__(this)
    function this.OnCancel()
        if this.cancelCallback then
            this.cancelCallback()
        end
        this.CloseUI()
    end