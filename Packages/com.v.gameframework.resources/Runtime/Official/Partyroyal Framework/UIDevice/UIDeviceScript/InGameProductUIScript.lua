
    local this = __CREATOR__.new()

    this.title  = __EX_VARIABLE__.component.text()
    this.price  = __EX_VARIABLE__.component.text()
    this.icon  = __EX_VARIABLE__.component.image()

    this.confirmButton  = __EX_VARIABLE__.vobject()
    this.ownedButton  = __EX_VARIABLE__.vobject()
    this.currencyIcon  = __EX_VARIABLE__.vobject()

    this.product = {}
    this.purchaseCallback = nil

    function this.OnStart()
    end
    
    function this.SetProduct(product, callback)
        this.product = product
        this.purchaseCallback = callback
        this.title.text = product.Title or ''
        this.price.text = product.Price and tostring(product.Price) or ''

        product:GetThumbnailAsync(function(thumbnail) 
            if thumbnail then
                this.icon.sprite = thumbnail
            end
        end)

        if product.IsPass then
            product:IsPurchasedAsync(this.SetIsPurchased)
        end
    end

    function this.SetIsPurchased(purchased)
        if not this.product.IsPass then
            return
        end

        if purchased then
            this.price.text = 'Owned'
            this.ownedButton:SetActive(true)
            this.confirmButton:SetActive(false)
            this.currencyIcon:SetActive(false)
        else
            this.price.text = this.product.Price and tostring(this.product.Price) or ''
            this.confirmButton:SetActive(true)
            this.currencyIcon:SetActive(true)
            this.ownedButton:SetActive(false)
        end
    end

    function this.SetProductType(isSelectedItem)
        local isActive = this.product and this.product.IsItem == isSelectedItem or false
        this.scriptObject.parent:SetActive(isActive)
    end

    __EX_FUNCTION__(this)
    function this.PurchaseProduct()
        this.purchaseCallback(this.product)
    end