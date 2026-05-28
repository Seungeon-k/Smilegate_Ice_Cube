-- GameObject -> { key -> LuaInstance }를 보관 (weak key로 릭 방지)
local REG = setmetatable({}, { __mode = "k" })

local M = {}

-- 인스턴스 등록. key는 클래스명 등 식별자(한 GO에 여러 스크립트 시 확장)
function M.bind(go, inst, key)
  key = key or "__default"
  local bucket = REG[go]
  if not bucket then
    bucket = {}
    REG[go] = bucket
  end
  bucket[key] = inst
end

-- 인스턴스 조회
function M.of(go, key)
  key = key or "__default"
  local bucket = REG[go]
  return bucket and bucket[key] or nil
end

-- 정리(선택): 파괴 시 레지스트리에서 제거
function M.unbind(go, key)
  key = key or "__default"
  local bucket = REG[go]
  if bucket then
    bucket[key] = nil
    if next(bucket) == nil then REG[go] = nil end
  end
end

return M
