-- emmy_attach.lua (robust)
local M = {}

local function join(a, b)
  local sep = package.config:sub(1,1) -- "\" (win) or "/"
  a = tostring(a or ""):gsub("[/\\]", sep)
  b = tostring(b or ""):gsub("[/\\]", sep)
  if a:sub(-1) == sep then return a .. b else return a .. sep .. b end
end

local function load_emmy_core(dll_dir)
  local dll = join(dll_dir, "emmy_core.dll")
  print(("[emmy_attach] dll path: %s"):format(dll))

  local loader, err = package.loadlib(dll, "luaopen_emmy_core")
  if not loader then
    print("[emmy_attach] loadlib failed: " .. tostring(err))
    return nil, "loadlib_failed"
  end
  print("[emmy_attach] loadlib ok: got loader function")

  local ok, mod = pcall(loader)
  if not ok then
    print("[emmy_attach] emmy_core init failed: " .. tostring(mod))
    return nil, "init_failed"
  end
  if type(mod) ~= "table" or type(mod.tcpConnect) ~= "function" then
    print("[emmy_attach] unexpected module: " .. tostring(mod))
    return nil, "bad_module"
  end
  print("[emmy_attach] emmy_core loaded: table w/ tcpConnect")
  return mod
end

function M.start(opt)
  print("[emmy_attach] start()")
  opt = opt or {}
  local host = opt.host or "127.0.0.1"
  local port = tonumber(opt.port or 9966)
  local wait = not not opt.wait
  local dll_dir = opt.dir or ""

  local emmy, why = load_emmy_core(dll_dir)
  if not emmy then
    if wait then error("[emmy_attach] abort: "..tostring(why)) end
    return false
  end

  print(("[emmy_attach] connecting to %s:%d ..."):format(host, port))
  local ok, err = pcall(function() emmy.tcpConnect(host, port) end)
  if not ok then
    print("[emmy_attach] tcpConnect failed: " .. tostring(err))
    if wait then error(err) end
    return false
  end

  print(("[emmy_attach] Attached to EmmyLua at %s:%d"):format(host, port))
  return true
end

return M
