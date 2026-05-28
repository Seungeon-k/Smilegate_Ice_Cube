--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
local rawget = rawget
local setmetatable = setmetatable
local type = type
local Vector3 = Vector3
local zero = Vector3.zero

local Bounds = 
{
	center = Vector3.zero,
	extents = Vector3.zero,
}

local get = tolua.initget(Bounds)

Bounds.__index = function(t,k)
	local var = rawget(Bounds, k)
	
	if var == nil then							
		var = rawget(get, k)
		
		if var ~= nil then
			return var(t)	
		end
	end
	
	return var
end

Bounds.__call = function(t, center, size)
	return setmetatable({center = center, extents = size * 0.5}, Bounds)		
end

function Bounds.New(center, size)	
	return setmetatable({center = center, extents = size * 0.5}, Bounds)		
end

function Bounds:Get()
	local size = self:GetSize()	
	return self.center, size
end

function Bounds:GetSize()
	return self.extents * 2
end

function Bounds:SetSize(value)
	self.extents = value * 0.5
end

function Bounds:GetMin()
	return self.center - self.extents
end

function Bounds:SetMin(value)
	self:SetMinMax(value, self:GetMax())
end

function Bounds:GetMax()
	return self.center + self.extents
end

function Bounds:SetMax(value)
	self:SetMinMax(self:GetMin(), value)
end

function Bounds:GetCenter()
    return self.center
end

function Bounds:SetMinMax(min, max)
	self.extents = (max - min) * 0.5
	self.center = min + self.extents
end

function Bounds:Encapsulate(point)
	self:SetMinMax(Vector3.Min(self:GetMin(), point), Vector3.Max(self:GetMax(), point))
end

function Bounds:Expand(amount)	
	if type(amount) == "number" then
		amount = amount * 0.5
		self.extents:Add(Vector3.New(amount, amount, amount))
	else
		self.extents:Add(amount * 0.5)
	end
end

function Bounds:Intersects(bounds)
	local min = self:GetMin()
	local max = self:GetMax()
	
	local min2 = bounds:GetMin()
	local max2 = bounds:GetMax()
	
	return min.x <= max2.x and max.x >= min2.x and min.y <= max2.y and max.y >= min2.y and min.z <= max2.z and max.z >= min2.z
end    

function Bounds:Contains(p)
	local min = self:GetMin()
	local max = self:GetMax()
	
	if p.x < min.x or p.y < min.y or p.z < min.z or p.x > max.x or p.y > max.y or p.z > max.z then
		return false
	end
	
	return true
end


-- Ray API 차이 흡수용(메서드/프로퍼티/바인딩 이름 차이 대응)
local function RayOrigin(ray)
    if ray.GetOrigin then return ray:GetOrigin() end
    if ray.get_origin then return ray:get_origin() end
    if ray.origin then return ray.origin end
    if ray.Origin then return ray.Origin end
    error("Ray origin API not found: expected GetOrigin/get_origin/origin")
end

local function RayDirection(ray)
    if ray.GetDirection then return ray:GetDirection() end
    if ray.get_direction then return ray:get_direction() end
    if ray.direction then return ray.direction end
    if ray.Direction then return ray.Direction end
    error("Ray direction API not found: expected GetDirection/get_direction/direction")
end

function Bounds:IntersectRay(ray)
	local tmin = -Mathf.Infinity
    local tmax =  Mathf.Infinity

    local c = self.center
    local o = RayOrigin(ray)
    local d = RayDirection(ray)
    local e = self.extents

    -- 축별 slab 검사(평행축 dir=0 안전 처리 포함)
    local function slab(origin, dir, center, extent)
        -- ray가 축에 평행한 경우: 시작점이 slab 범위 밖이면 교차 불가
        if dir == 0 then
            if origin < center - extent or origin > center + extent then
                return false
            end
            return true
        end

        local inv = 1 / dir
        local t0 = ((center - extent) - origin) * inv
        local t1 = ((center + extent) - origin) * inv
        if t0 > t1 then t0, t1 = t1, t0 end

        if t0 > tmin then tmin = t0 end
        if t1 < tmax then tmax = t1 end
        if tmin > tmax then return false end
        return true
    end

    if not slab(o.x, d.x, c.x, e.x) then return false end
    if not slab(o.y, d.y, c.y, e.y) then return false end
    if not slab(o.z, d.z, c.z, e.z) then return false end

    -- 박스가 ray의 뒤쪽에만 있으면 실패(원본과 동일한 성격의 조건)
    if tmax < 0 then return false end

    return true, tmin
end

function Bounds:ClosestPoint(point)
	local c = self.center
    local v = point - c

    local ex, ey, ez = self.extents.x, self.extents.y, self.extents.z
    local cx, cy, cz = v.x, v.y, v.z

    local distance = 0
    local delta

    if cx < -ex then
        delta = cx + ex; distance = distance + delta * delta; cx = -ex
    elseif cx > ex then
        delta = cx - ex; distance = distance + delta * delta; cx = ex
    end

    if cy < -ey then
        delta = cy + ey; distance = distance + delta * delta; cy = -ey
    elseif cy > ey then
        delta = cy - ey; distance = distance + delta * delta; cy = ey
    end

    if cz < -ez then
        delta = cz + ez; distance = distance + delta * delta; cz = -ez
    elseif cz > ez then
        delta = cz - ez; distance = distance + delta * delta; cz = ez
    end

    if distance == 0 then
        return point, 0
    else
        local outPoint = Vector3.New(cx, cy, cz) + c
        return outPoint, distance  -- 제곱거리 반환
    end
end

function Bounds:Destroy()
	self.center  = nil
    self.extents = nil
end

Bounds.__tostring = function(self)	
	return string.format("Center: %s, Extents %s", tostring(self.center), tostring(self.extents))
end

Bounds.__eq = function(a, b)
	return a.center == b.center and a.extents == b.extents
end

get.size = Bounds.GetSize
get.min = Bounds.GetMin
get.max = Bounds.GetMax

UnityEngine.Bounds = Bounds
setmetatable(Bounds, Bounds)
return Bounds
