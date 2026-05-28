-- 필드 선언/체이닝 DSL
local M, C = {}, {}
local function node(t) t.__is_exposed = true; return setmetatable(t, { __index = C }) end


local function normalize_sig(list)
  local out = {}
  for i, v in ipairs(list or {}) do
    if type(v) == "string" then
      -- "int damage" 또는 "int" 형태 허용
      local t, name = v:match("^%s*(%S+)%s*(.*)$")
      name = (name ~= "" and name) or ("arg"..i)
      out[#out+1] = { type=t, name=name }
    elseif type(v) == "table" and v.__is_exposed then
      local t = v._type
      local n = ("arg"..i)
      out[#out+1] = { type=t, name=n }
    elseif type(v) == "table" then
      -- {type="int", name="damage"} 또는 {"int","damage"} 형태
      local t = v.type or v[1]
      local n = v.name or v[2] or ("arg"..i)
      out[#out+1] = { type=t, name=n }
    end
  end
  return out
end

-- 원소 타입 정규화
local function elem_schema(elem)
  if type(elem) == "string" then
    return { _type = elem }                     -- ex.list("float"), "string", "vector3" 등
  elseif type(elem) == "table" and elem.__is_exposed then
    -- ex.list(ex.vector3()), ex.list(ex.float():range(0,1)) 처럼 노드 자체를 원소 타입으로
    return {
      _type       = elem._type,
      _default    = elem._default,               -- 원소 디폴트(있으면)
      _group      = elem._group,
      _tooltip    = elem._tooltip,
      _unity      = elem._unity,
      _signature  = elem._signature,
      _returns    = elem._returns,
      _private    = elem._private,
      _to_lua     = elem._to_lua,
    }
  elseif type(elem) == "table" then
    -- ex.list{ type="float", range={0,1} } 같은 수동 명세도 허용
    return elem
  elseif type(elem) == "userdata" and elem.FullName then
    -- typeof(T) 형태일 경우
    return { _type = elem.Name }
  else
    return { _type = "any" }
  end
end

function M.float(d)        return node{ _type="float",   _default=d } end
function M.int(d)          return node{ _type="int",     _default=d } end
function M.bool(d)         return node{ _type="bool",    _default=d } end
function M.string(d)       return node{ _type="string",  _default=d } end
function M.vector2(x,y)    return node{ _type="vector2", _default={x or 0, y or 0} } end
function M.vector3(x,y,z)  return node{ _type="vector3", _default={x or 0, y or 0, z or 0} } end
function M.vector4(x,y,z,w)  return node{ _type="vector4", _default={x or 0, y or 0, z or 0, w or 0} } end
function M.color(hex)      return node{ _type="color",   _default=hex } end
function M.list(spec)      return node{ _type="list",    _elem = elem_schema(spec), _default = nil } end
function M.event(...)
  local sig
  if select('#', ...) == 1 and type((...)) == "table" then
    if (...).__is_exposed then
      sig = normalize_sig({ ... })    -- ex.event(ex.int())
    else
      sig = normalize_sig((...))      -- ex.event{ ... }
    end
  else
    sig = normalize_sig({ ... })    -- ex.event("int","string")
  end
  return node{ _type="event", _signature=sig, _returns=nil }
end

-- UI Vo
local function button()          return node{ _type="ButtonVo",  _default=nil } end
local function image()          return node{ _type="ImageVo",  _default=nil } end
local function text()           return node{ _type="TextMeshProVo",  _default=nil } end
local function slider()         return node{ _type="SliderVo",  _default=nil } end
local function toggle()         return node{ _type="ToggleButtonVo",  _default=nil } end
local function dropdown()       return node{ _type="DropdownVo",  _default=nil } end
local function rawImage()       return node{ _type="RawImageVo",  _default=nil } end
local function inputField()     return node{ _type="InputFieldVo",  _default=nil } end
local function scrollBar()      return node{ _type="ScrollBarVo",  _default=nil } end
local function scrollView()     return node{ _type="ScrollViewVo",  _default=nil } end

-- Custom UI Vo
local function targetTracker()  return node{ _type="TargetTrackerVo",  _default=nil } end

-- script vo
local function script()             return node{ _type="ScriptObject", _default=nil } end
local function vo()                 return node{ _type="VObject", _default=nil } end
local function backViewController() return node{ _type="BackViewController", _default=nil } end
local function buff()               return node{ _type="Buff", _default=nil } end
local function cameraController()   return node{ _type="CameraController", _default=nil } end
local function character()          return node{ _type="Character", _default=nil } end
local function clientScript()       return node{ _type="ClientScript", _default=nil } end
local function container2D()        return node{ _type="Container2D", _default=nil } end
local function container3D()        return node{ _type="Container3D", _default=nil } end
local function gameEntity()         return node{ _type="GameEntity", _default=nil } end
local function globalVolume()       return node{ _type="GlobalVolume", _default=nil } end
local function inventory()          return node{ _type="Inventory", _default=nil } end
local function item()               return node{ _type="Item", _default=nil } end
local function penguinCharacter()   return node{ _type="PenguinCharacter", _default=nil } end
local function playerSpawnPoint()   return node{ _type="PlayerSpawnPoint", _default=nil } end
local function player()             return node{ _type="Player", _default=nil } end
local function renderSetting()      return node{ _type="RenderSetting", _default=nil } end
local function serverScript()       return node{ _type="ServerScript", _default=nil } end
local function topViewController()  return node{ _type="TopViewController", _default=nil } end
local function uiGameObject()       return node{ _type="UIGameObject", _default=nil } end
local function worldGameObject()    return node{ _type="WorldGameObject", _default=nil } end

M.vobject = {
  -- 공통 및 기능성
  vobject = vo,
  script = script,
  clientScript = clientScript,
  serverScript = serverScript,
  
  -- 컨트롤러 및 시스템
  backViewController = backViewController,
  cameraController = cameraController,
  topViewController = topViewController,
  renderSetting = renderSetting,
  globalVolume = globalVolume,
  
  -- 게임 오브젝트 및 엔티티
  gameEntity = gameEntity,
  uiGameObject = uiGameObject,
  worldGameObject = worldGameObject,
  character = character,
  penguinCharacter = penguinCharacter,
  player = player,
  playerSpawnPoint = playerSpawnPoint,
  
  -- 인벤토리 및 아이템
  inventory = inventory,
  item = item,
  buff = buff,
  
  -- 컨테이너
  container2D = container2D,
  container3D = container3D,
  
  -- UI 요소 (기존 요청 항목 포함)
  button = button,
  image = image,
  text = text,
  slider = slider,
  toggle = toggle,
  dropdown = dropdown,
  rawImage = rawImage,
  inputField = inputField,
  scrollBar = scrollBar,
  scrollView = scrollView,
  targetTracker = targetTracker
}

setmetatable(M.vobject, {
  __call = function(self, ...)
      -- M.vobject() 호출 시 실행되는 함수
     return node{ _type="vobject",  _default=nil }
  end
})

local function unity_button()     return node{ _type="Button",  _default=nil } end
local function unity_image()     return node{ _type="Image",  _default=nil } end
local function unity_canvas()     return node{ _type="Canvas",  _default=nil } end
local function unity_slider()     return node{ _type="Slider",  _default=nil } end
local function unity_text()     return node{ _type="TextMeshProUGUI",  _default=nil } end

local function unity_animation()     return node{ _type="Animation",  _default=nil } end
local function unity_animator()     return node{ _type="Animator",  _default=nil } end
local function unity_transform()     return node{ _type="Transform",  _default=nil } end
local function unity_renderer()     return node{ _type="Renderer",  _default=nil } end
local function unity_collider()     return node{ _type="Collider",  _default=nil } end
local function unity_rigidbody()     return node{ _type="Rigidbody",  _default=nil } end
local function unity_particlesystem()     return node{ _type="ParticleSystem",  _default=nil } end
local function unity_audiosource()     return node{ _type="AudioSource",  _default=nil } end

M.component = {
  button = unity_button,
  image = unity_image,
  canvas = unity_canvas,
  slider = unity_slider,
  text = unity_text,
  animation = unity_animation,
  animator = unity_animator,
  transform = unity_transform,
  renderer = unity_renderer,
  collider = unity_collider,
  rigidbody = unity_rigidbody,
  particleSystem = unity_particlesystem,
  audioSource = unity_audiosource
}

local function audioClip()    return  node{ _type="AudioClip",  _default=nil } end
local function animationClip()    return  node{ _type="AnimationClip",  _default=nil } end
local function sprite()    return  node{ _type="Sprite",  _default=nil } end
local function texture()    return  node{ _type="Texture",  _default=nil } end
local function texture2D()    return  node{ _type="Texture2D",  _default=nil } end
local function material()    return  node{ _type="Material",  _default=nil } end

M.asset = {
  audioClip = audioClip,
  animationClip = animationClip,
  sprite = sprite,
  texture = texture,
  texture2D = texture2D,
  material = material
}

-- list 생성기
-- ex.list("float")
-- ex.list{ "float" }         -- sugar
-- ex.list(ex.vector3())      -- 노드 기반
--[[
function M.list(spec)
  local e = (type(spec)=="table" and not spec.__is_exposed and spec[1] and type(spec[1])=="string")
            and elem_schema(spec[1]) or elem_schema(spec)
  return node{ _type="list", _elem=e, _default={} }
end
]]--


function C.group(self,g)       self._group=g; return self end
function C.tooltip(self,t)     self._tooltip=t; return self end
function C.private(self)       self._private = true; return self end
function C.default(self, ...)
  if self._type == "list" then
    local n = select('#', ...)
    if n == 1 and type((...)) == "table" then
      self._default = (...)
    else
      local arr = {}
      for i = 1, n do arr[i] = select(i, ...) end
      self._default = arr
    end
  else
    self._default = select(1, ...)
  end
  return self
end
function C.lua(self)          self._to_lua = true; return self end

--[[
function C.setDefault(self, v)
  if self._type == "list" then
    assert(type(v) == "table", "list.default expects a table (array-like)")
    self._default = v          -- 여기선 '형태'만 보관
    self._default_is_list = true
  else
    self._default = v          -- 스칼라/객체 등은 그대로
  end
  return self
end
]]--

-- 반환형 정의 체이닝: :returns("bool") 또는 :returns{"bool"} 또는 :returns({"bool handled"})
-- 현재는 미지원, 차후 논의하고 반영
--[[
function C.returns(self, ...)
  if select('#', ...) == 1 and type((...)) == "table" then
    self.returns = normalize_sig((...))
  else
    self.returns = normalize_sig({ ... })
  end
  return self
end
]]--

return M