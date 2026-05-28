local M = {}

UE = UE or {}
UE.events = UE.events or {}   -- ["ShowText"] = { args=..., fn=..., table=UI }

-- =========================
-- 이벤트 리스너 노출 통합부
-- =========================

-- 간단 타입 축약 (원하면 더 추가)
local function _map_type(t)
  if t == "i" or t == "int"    then return "int"    end
  if t == "f" or t == "float"  then return "float"  end
  if t == "s" or t == "string" then return "string" end
  if t == "b" or t == "bool" then return "bool" end
  if t == "v2" or t == "vector2" or t == "Vector2" then return "vector2" end
  if t == "v3" or t == "vector3" or t == "Vector3" then return "vector3" end
  if t == "v4" or t == "vector4" or t == "Vector4" then return "vector4" end
  if t == "c" or t == "color" or t == "Color" then return "color" end
  if t == "o" or t == "obj" or t == "object" or t == "Object" then return "object" end
  return t
end

-- "int" | {"int"} | {args="int"} | {args={"int"}} | nil -> {"int"} | {}
local function _norm_args(meta)
  if meta == nil then return {} end
  if type(meta) == "string" then return { _map_type(meta) } end
  if type(meta) == "table" then
    local a = meta.args or meta
    if type(a) == "string" then a = { a } end
    local out = {}
    if type(a) == "table" then
      for i,v in ipairs(a) do out[i] = _map_type(v) end
    end
    return out
  end
  return {}
end

-- 전역에서 테이블 이름 추정(선택: 필요하면 모듈에 __modname 같은 힌트를 우선 사용)
local function _guess_table_name(t)
  for k, v in next, _G, nil do
    if type(k) == "string" and type(v) == "table" and rawequal(v, t) then
      return k
    end
  end
end

-- 가변 인자 -> {"int","float",...} 로 정규화
-- 허용: "int","float"  / {"int","float"} / {args={"int","float"}} / "i","f" / nil
local function _collect_args(first, ...)
  local out = {}

  local function add(x)
    if x == nil then return end
    local tx = type(x)
    if tx == "string" then
      out[#out+1] = _map_type(x)
    elseif tx == "table" and x.__is_exposed then
      out[#out+1] = _map_type(x._type)
    elseif tx == "table" then
      local a = x.args or x
      if type(a) == "string" then
        out[#out+1] = _map_type(a)
      elseif type(a) == "table" then
        for _,v in ipairs(a) do
          if type(v) == "string" then out[#out+1] = _map_type(v) end
        end
      end
    end
  end

  add(first)
  for i,v in ipairs({...}) do add(v) end
  return out
end

local function _register_event(tbl, key, fn, args)
  -- 전역/메서드는 지원하지 않으므로 테이블 이름 없으면 스킵
  --local tblname = _guess_table_name(tbl)
  --if not tblname then return end      -- 익명 테이블은 등록 안 함
  --local path = tblname .. "." .. tostring(key)  -- "UI.ShowText" 형태만
  UE.events[key] = { args = args, fn = fn, table = tbl }
  --print("[expose] event:", path)
  
end

-- target 테이블의 "다음 1회 함수 대입"을 가로채 등록
local function _once_hook(target_tbl, meta)    
  local args = _norm_args(meta)
  local mt = getmetatable(target_tbl) or {}
  local prev = mt.__newindex
  local done = false

  mt.__newindex = function(t, k, v)
    -- 새 키에 함수가 들어오는 경우만 (재정의는 Lua 규칙상 __newindex가 안 탈 수 있음)    
    if not done and type(v) == "function" and rawget(t, k) == nil then
      _register_event(t, k, v, args)
      done = true
      -- 원복
      local cur = getmetatable(t) or {}
      cur.__newindex = prev
      setmetatable(t, cur)
    end
    return prev and prev(t, k, v) or rawset(t, k, v)
  end

  setmetatable(target_tbl, mt)
end

-- 기본 타깃( ex: expose "string" 을 쓰고 싶을 때 필요 )
local _default_target = nil

-- expose.target(UI) : 이후 expose "int" 처럼 테이블을 생략 가능
function M.target(tbl) _default_target = tbl end

-- 편의: 일시적으로 타깃 바꿔 블록 실행
function M.using(tbl, fn)
  local prev = _default_target
  _default_target = tbl
  local ok, err = pcall(fn)
  _default_target = prev
  if not ok then print(err, 2) end
end

-- 🔥 핵심: 가변 인자 지원
-- 1) expose(UI, "int", "float")      -- 명시 타깃 + varargs
-- 2) expose "int", "float"            -- 기본 타깃 지정 후 varargs
-- 3) 기존도 OK: expose(UI, {"int","float"}) / expose{ "int","float" } / expose{args={"int","float"}}
function M.__call(_, a, ...)
  local rest_n = select("#", ...)
  --if type(a) == "table" and rest_n > 0 then
  if type(a) == "table" then
    -- 첫 인자가 테이블이면 '타깃'으로 보고, 나머지를 타입 목록으로 수집
    if rest_n <= 0 then
      return _once_hook(a, nil)
    else
      return _once_hook(a, _collect_args(...))
    end    
  else
    -- 기본 타깃 사용
    local tgt = _default_target
    if not tgt then error("expose: default target not set. call expose.target(<table>) or use expose(<table>, ...)", 2) end
    return _once_hook(tgt, _collect_args(a, ...))
  end
end

-- 축약: expose.s(UI) / expose.i() ...
function M.i(tbl) return tbl and M(tbl, "int")      or M("int")    end
function M.f(tbl) return tbl and M(tbl, "float")    or M("float")  end
function M.s(tbl) return tbl and M(tbl, "string")   or M("string") end
function M.b(tbl) return tbl and M(tbl, "bool")     or M("bool") end
function M.v2(tbl) return tbl and M(tbl, "vector2") or M("vector2") end
function M.v3(tbl) return tbl and M(tbl, "vector3") or M("vector3") end
function M.v4(tbl) return tbl and M(tbl, "vector4") or M("vector4") end
function M.c(tbl) return tbl and M(tbl, "color")    or M("color") end
function M.o(tbl) return tbl and M(tbl, "object")   or M("object") end

-- 모듈을 함수처럼 쓸 수 있게
-- debug.setmetatable(M, { __call = M.__call })  -- Lua 5.1(tolua)면 setmetatable(M, {__call=...}) 사용
setmetatable(M, { __call = M.__call })     -- ↑ 환경에 맞게 한 줄만 남기세요


return M