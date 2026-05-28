
    local this = __CREATOR__.new()

    local RESULT_SUCCESS = 1
    local CLOSE_ANIM_KEY = 'Popup_Close_03'
    local TOGGLE_ON_KEY = 'Btn_Toggle_Parts_ON'
    local TOGGLE_OFF_KEY = 'Btn_Toggle_Parts_OFF'

    this.productUI  = __EX_VARIABLE__.vobject()
    this.popupUI  = __EX_VARIABLE__.vobject()
    this.content  = __EX_VARIABLE__.vobject()
    this.animator  = __EX_VARIABLE__.component.animator()
    this.itemTabAnimator  = __EX_VARIABLE__.component.animator()
    this.passTabAnimator  = __EX_VARIABLE__.component.animator()

    this.productScripts = {}
    this.resultScript = nil

    local isSelectedItem = true
    local isInputLock = false

    function this.OnStart()
        this.serviceApi.inGameProductsService:LoadShop(this.OnLoadShop)
        this.serviceApi.inGameProductsService:GetProducts(this.OnGetProducts)

        isInputLock = this.serviceApi.inputService.isInputLock
        this.serviceApi.inputService.isInputLock = true
    end

    function this.OnLoadShop(code, message)
        if code ~= RESULT_SUCCESS then
            return
        end
    end

    function this.OnGetProducts(code, message, products)
        if code ~= RESULT_SUCCESS then
            return
        end

        this.productScripts = {}

        for _, product in ipairs(products) do
            if product and not product.IsDeleted and product.IsActive then
                local productUI = this.serviceApi.uiService:Instantiate(this.productUI)
                productUI:SetParent(this.content)

                local productScript = productUI:Find('Script'):GetLua()
                productScript.SetProduct(product, this.PurchaseProduct)
                productScript.SetProductType(true)
                table.insert(this.productScripts, productScript)
            end
        end
    end

    function this.UpdateProductType(isItem)
        if isSelectedItem == isItem then
            return
        end

        for _, productScript in ipairs(this.productScripts) do
            productScript.SetProductType(isItem)
        end

        isSelectedItem = isItem
        this.itemTabAnimator:SetTrigger(isItem and TOGGLE_ON_KEY or TOGGLE_OFF_KEY)
        this.passTabAnimator:SetTrigger(isItem and TOGGLE_OFF_KEY or TOGGLE_ON_KEY)
    end

    function this.PurchaseProduct(product)
        this.serviceApi.inGameProductsService:PurchaseProduct(product.ProductId, this.OnPurchaseProduct)
    end

    function this.OnPurchaseProduct(code, message, productId)
        local popupUI = this.serviceApi.uiService:Instantiate(this.popupUI)
        popupScript = popupUI:Find('Script'):GetLua()

        if code == RESULT_SUCCESS then
            local productScript = this.GetProductScript(productId)
            if productScript and productScript.product.IsPass then
                productScript.SetIsPurchased(true)
            end

            local title = 'Success'
            local msg = 'Your purchase has been completed.'
            local confirm = 'OK'
            popupScript.SetMessages(title, msg)
            popupScript.SetButtons(confirm)
        else 
            local title = 'Fail'
            local msg = 'Your purchase has been failed.'
            local confirm = 'OK'
            popupScript.SetMessages(title, tostring(msg) .. '(' .. tostring(code) .. ')')
            popupScript.SetButtons(confirm)
        end
    end

    function this.GetProductScript(productId)
        for _, productScript in ipairs(this.productScripts) do
            if productScript.product.ProductId == productId then
                return productScript
            end
        end
        return nil
    end

    __EX_FUNCTION__(this)
    function this.SelectItem()
        this.UpdateProductType(true)
    end

    __EX_FUNCTION__(this)
    function this.SelectPass()
        this.UpdateProductType(false)
    end

    __EX_FUNCTION__(this)
    function this.CloseUI()
        this.serviceApi.inGameProductsService:CloseShop()
        this.serviceApi.inputService.isInputLock = isInputLock
        this.animator:Play(CLOSE_ANIM_KEY)

        this.scriptObject:AsyncCall(function() 
            VFramework.WaitForSeconds(0.3)
            this.scriptObject.parent:Destroy()
        end)
    end