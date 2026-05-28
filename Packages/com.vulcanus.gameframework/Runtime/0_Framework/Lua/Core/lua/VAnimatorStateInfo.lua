--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
local rawget = rawget
local setmetatable = setmetatable

local AnimatorStateInfo = {}
local get = tolua.initget(AnimatorStateInfo)

AnimatorStateInfo.__index = function(t,k)
	local var = rawget(AnimatorStateInfo, k)
		
	if var == nil then							
		var = rawget(get, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

--c# 创建
function AnimatorStateInfo.New(fullPathHash, length, loop, normalizedTime, shortNameHash, speed, speedMultiplier, tagHash)
	local info = {fullPathHash = fullPathHash or 0, length = length or 0, loop = loop or false, normalizedTime = normalizedTime or 0, shortNameHash = shortNameHash or 0, speed = speed or 0, speedMultiplier = speedMultiplier or 0, tagHash = tagHash or 0}
	setmetatable(info, AnimatorStateInfo)
	return info
end

function AnimatorStateInfo:IsTag(tagName)
    local hash = VFramework.Animator.StringToHash(tagName)
    return hash == self.tagHash
end

function AnimatorStateInfo:IsName(name)
    local hash = VFramework.Animator.StringToHash(name) 
    return  hash == self.fullPathHash or hash == self.shortNameHash
end

UnityEngine.AnimatorStateInfo = AnimatorStateInfo
setmetatable(AnimatorStateInfo, AnimatorStateInfo)
return AnimatorStateInfo