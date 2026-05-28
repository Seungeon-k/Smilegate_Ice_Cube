-- this 테이블을 프록시로 만들어 스키마/데이터/라이브동기화 지원
local M = {}

local function attach_proxy(t)
  local __schema, __defaults, __declared = {}, {}, {}
  local __data, __watchers = {}, {}

  local function record_field(name, f)
    __declared[name] = true
    __schema[name] = {
      type=f._type,
      default=f._default,
      group=f._group,
      tooltip=f._tooltip,
      unity=f._unity,
      signature=f._signature,
      returns=f._returns, 
      private = f._private == true,   -- ★
      to_lua = f._to_lua == true,
      elem=f._elem,      -- ★ list 메타 포함
    }
    __defaults[name] = f._default
  end

  local function _is_owner_call(self)
    local info = getsrc(3)
    local src = info and info.source
    return src ~= nil and src == rawget(self, "__owner_src")
  end

  local function wrap_list(self, key, list)
    local backing = list
    local methods = {}

    function methods.add(_, v)
      local n = #backing
      local idx = n + 1
      table.insert(backing, idx, v)
      --__data[key] = backing
      local cb = rawget(self, "_cs_set"); if cb ~= nil then cb:Add(key, idx, v) end
      local w = __watchers[key]; if w then w(backing) end
    end

    function methods.remove(_, pos)
      local n = #backing
      local idx = pos or n
      print("call remove:"..tostring(idx))
      if idx < 1 or idx > n then return nil end
      table.remove(backing, idx)
      --__data[key] = backing
      local cb = rawget(self, "_cs_set"); if cb ~= nil then cb:Remove(key, idx) end
      local w = __watchers[key]; if w then w(backing) end
    end
    

    local mt = {
      __index = function(_, k)
        if methods[k] then return methods[k] end
        return backing[k]
      end,
      __len = function(_) return #backing end,
      -- __ipairs = function(_) return ipairs(backing) end, -- Global로 C#에서 주입
      __pairs = function(_) return pairs(backing) end,
      __newindex = function(_, k, v) -- 숫자 인덱스 대입 감지
        backing[k] = v
        __data[key] = backing
        local cb = rawget(self, "_cs_set"); if cb ~= nil then cb:Notify(key, k, v) end
        local w = __watchers[key]; if w then w(backing) end
      end,
    }
    return setmetatable({}, mt)
  end

  local mt = {
    __index = function(self, k)
      if k == "__schema" then return __schema end

      if k == "__bind_data" then
        return function(_, tbl)
          tbl = tbl or {}
          -- list 필드는 들어온 테이블을 래핑
          for name,_ in pairs(__declared) do
            if __schema[name].type == "list" and type(tbl[name])=="table" then
              tbl[name] = wrap_list(self, name, tbl[name])
            end
          end
          __data = tbl or __data        -- C#이 만든 LuaTable을 그대로 사용
          rawset(self, "_data", __data) -- 선택: 디버그 노출
        end
      end

      if k == "__apply" then
        return function(_, key, val)
          if __declared[key] then
            if __schema[key].type == "list" and type(val)=="table" then
              val = wrap_list(self, key, val)
            end
            __data[key] = val           -- C#→Lua 실시간 반영(리스트 포함)
            local w = __watchers[key]; if w then w(val) end
          end
        end
      end
      if k == "__watch" then
        return function(_, key, fn) __watchers[key] = fn end
      end


      if __declared[k] then
        local spec = __schema[k]
        if spec and spec.private and not _is_owner_call(self) then
          print("attempt to read private field '"..k.."'", 2)
          return nil
        end
        local v = __data[k]
        if v ~= nil then return v end
        -- ⚠️ 리스트 디폴트는 공유 테이블일 수 있으니, 항상 C#에서 __bind_data로 채워주는 게 전제
        if __schema[k].type == "list" and type(__defaults[k])=="table" then
          cp = wrap_list(self, k, __defaults[k])
          __data[k] = cp
          return cp
        end
        return __defaults[k]
      end
      return nil
    end,

    __newindex = function(self, k, v)
      if type(v) == "table" and v.__is_exposed then
        record_field(k, v)                   -- 선언 대입: 스키마만 기록
        return
      end

      if __declared[k] then                 -- 노출 필드 런타임 쓰기
        local spec = __schema[k]
        if spec and spec.private and not _is_owner_call(self) then
          print("attempt to write private field '"..k.."'", 2)
          return
        end
        if __schema[k].type == "list" and type(v)=="table" then
          v = wrap_list(self, k, v)
        end
        __data[k] = v
        local cb = rawget(self, "_cs_set")
        if cb ~= nil then
          cb:Notify(k, v)
        end
        local w = __watchers[k]; if w then w(v) end
        return
      end
      rawset(self, k, v)                    -- 일반 키 저장(함수 포함)
    end
  }

  return setmetatable(t, mt)
end

function M.new()
  local inst = attach_proxy({})
  local info = getsrc(2)
  rawset(inst, "__owner_src", info and info.source or "?")
  return inst
end

function M.decorate(existing)
  local inst = attach_proxy(existing or {})
  local info = getsrc(2)
  rawset(inst, "__owner_src", info and info.source or "?")
  return inst
end

return M