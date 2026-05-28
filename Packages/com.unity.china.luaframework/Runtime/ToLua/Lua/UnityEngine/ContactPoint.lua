--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
local rawget = rawget
local setmetatable = setmetatable
local Vector3 = Vector3

local ContactPoint = 
{
    point = Vector3.zero,
	normal = Vector3.zero,
}

local get = tolua.initget(ContactPoint)

ContactPoint.__index = function(t,k)
	local var = rawget(ContactPoint, k)
		
	if var == nil then							
		var = rawget(get, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

--c# 创建
function ContactPoint.New(point, normal, thisCollider, otherCollider, separation)    
	local p = {}
	p.point = point
	p.normal = normal
	p.thisCollider = thisCollider
	p.otherCollider = otherCollider
	p.separation = separation or 0
	
	setmetatable(p, ContactPoint)
	
	return p
end

UnityEngine.ContactPoint = ContactPoint
setmetatable(ContactPoint, ContactPoint)
return ContactPoint
