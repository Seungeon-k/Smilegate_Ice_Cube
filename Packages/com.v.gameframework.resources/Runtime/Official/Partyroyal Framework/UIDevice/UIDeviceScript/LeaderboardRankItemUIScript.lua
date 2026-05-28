
    local this = __CREATOR__.new()

	this.rankText  = __EX_VARIABLE__.component.text()
	this.nameText  = __EX_VARIABLE__.component.text()
	this.mainScoreText  = __EX_VARIABLE__.component.text()
	this.subScore1Text  = __EX_VARIABLE__.component.text()
	this.subScore2Text  = __EX_VARIABLE__.component.text()
	
	this.rankGroupNode = __EX_VARIABLE__.vobject()
	this.rankUpNode = __EX_VARIABLE__.vobject()
	this.rankDownNode = __EX_VARIABLE__.vobject()
	this.rankNewNode = __EX_VARIABLE__.vobject()
	this.rankUpCountText  = __EX_VARIABLE__.component.text()
	this.rankDownCountText  = __EX_VARIABLE__.component.text()
	
	function this.SetRankItem(info, item)
		if not item then
			this.rankText.text = '-'
			this.nameText.text = '-'
			this.mainScoreText.text = '-'
			this.subScore1Text.text = '-'
			this.subScore2Text.text = '-'
			
			this.subScore1Text.vObject:SetActive(#info.scores > 1)
			this.subScore2Text.vObject:SetActive(#info.scores > 2)
			
			this.rankGroupNode:SetActive(false)
			
			return
		end
		
		this.rankText.text = item.rank and tostring(item.rank) or ''
		this.nameText.text = item.name and tostring(item.name) or ''
		
		this.mainScoreText.text = info.scores[1].isTime and this.FormatTime(item.scores[1]) or this.FormatN0(item.scores[1])
		
		if #info.scores > 1 then
			this.subScore1Text.vObject:SetActive(true)

			local score1 = #item.scores > 1 and item.scores[2] or 0
			this.subScore1Text.text = info.scores[2].isTime and this.FormatTime(score1) or this.FormatN0(score1)
		else 
			this.subScore1Text.vObject:SetActive(false)
		end
		
		if #info.scores > 2 then
			this.subScore2Text.vObject:SetActive(true)

			local score2 = #item.scores > 2 and item.scores[3] or 0
			this.subScore2Text.text = info.scores[3].isTime and this.FormatTime(score2) or this.FormatN0(score2)
		else 
			this.subScore2Text.vObject:SetActive(false)
		end

		this.rankGroupNode:SetActive(info.usePeriod)

		if info.usePeriod then
			local isRankUp = item.prevRank > 0 and item.prevRank > item.rank
			local isRankDown = item.prevRank > 0 and item.prevRank < item.rank
			local isNew = item.prevRank == 0

			this.rankUpNode:SetActive(isRankUp)
			this.rankDownNode:SetActive(isRankDown)
			this.rankNewNode:SetActive(isNew)

			if isRankUp then
				this.rankUpCountText.text = tostring(item.prevRank - item.rank)
			end

			if isRankDown then
				this.rankDownCountText.text = tostring(item.rank - item.prevRank)
			end
		end
	end

	function this.FormatTime(value)
		if value == nil then value = 0 end
		if value < 0 then value = 0 end

		local cs     = value % 1000          -- 0..999 (milliseconds)
		local totalS = math.floor(value / 1000)
		local s      = totalS % 60           -- 0..59
		local totalM = math.floor(totalS / 60)
		local m      = totalM % 60           -- 0..59
		local totalH = math.floor(totalM / 60)
		local h      = totalH % 24           -- 0..23
		local d      = math.floor(totalH / 24)

		if d > 0 then
			return string.format("%02dD : %02dh : %02d : %02d", d, h, m, s)
		end
		if h > 0 then
			return string.format("%02dh : %02d : %02d", h, m, s)
		end

		local cs2 = math.floor(cs / 10)
		return string.format("%02dm : %02ds/%02d", m, s, cs2)
	end

	function this.FormatN0(value)
		if value == nil then
			return "0"
		end

		value = math.floor(value + 0.5)

		local s = tostring(value)
		local sign = ''

		if s:sub(1,1) == '-' then
			sign = '-'
			s = s:sub(2)
		end

		s = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
		s = s:gsub('^,', '')

		return sign .. s
	end