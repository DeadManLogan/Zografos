-- 64x64 Roman gladius (Mainz pattern), inventory item.
-- 45-degree pose: tip bottom-left, pommel top-right. Light from the top-left,
-- i.e. perpendicular to the blade axis.
--
-- References (attribute taken):
--   gladius_01 (replica)      -> proportions: long tapering point, ribbed ivory
--                                grip, big oval wooden pommel, domed guard with a
--                                flat plate on the blade side
--   gladius_02 (Mainz, BM)    -> gilded fittings -> brass trims as ochre accent
--   gladius_03 (replica)      -> pommel nut, crisp diamond ridge on the blade
-- Transformation: hilt exaggerated (~37% of length vs ~30%) so the
-- pommel/guard/ribs read at 1:1; fittings simplified to plate + 2 collars + nut.
--
-- Geometry works in diagonal coordinates:
--   t = x - y       along the axis, grows towards the pommel
--   o = x + y - 63  across the axis, negative = lit (top-left) side
-- Constant-o lines are clean 45-degree pixel lines; the point's edges are
-- |o| = (t - TIP_T) / 5, which land on clean 3:2 pixel lines.
local px = dofile("tools/aseprite/lib/pixel.lua")
local C = px.C

local W, H = 64, 64
local S0 = 63

-- ramps dark -> light (hue-shifted: cool/purple at the bottom, warm at the top)
local WOOD  = { C.plum_dark, C.umber, C.terracotta, C.ochre, C.sand }
local BRASS = { C.umber, C.terracotta, C.ochre, C.sand, C.bone }
local IVORY = { C.aubergine, C.dusk, C.mauve, C.bone }

-- axial layout (t ranges, inclusive)
local TIP_T     = -57
local BLADE_END = 15
local BLADE_HW  = 5                    -- half-width incl. outline
local PLATE     = { 16, 17 }           -- brass plate on the blade side of the guard
local GUARD_T0, GUARD_AT, GUARD_AS = 17, 9.5, 8.5   -- half-ellipsoid dome
local GUARD     = { 18, 25 }
local COLLAR1   = { 26, 27 }
local GRIP      = { 28, 42 }
local VALLEYS   = { [31] = true, [35] = true, [39] = true }  -- 4 finger ribs
local COLLAR2   = { 43, 44 }
local POM_T, POM_AT, POM_AS = 52, 7.4, 9.0          -- pommel ellipse (slightly wider than long)
local NUT       = { 58, 61 }

local function within(t, r) return t >= r[1] and t <= r[2] end

-- which part covers (t, o)? returns name
local function part(t, o)
  local ao = math.abs(o)
  if within(t, NUT) and ao <= (t >= 60 and 1 or 2) then return "nut" end
  local dt = (t - POM_T) / POM_AT
  if math.abs(dt) <= 1 and ao <= POM_AS * math.sqrt(1 - dt * dt) then return "pommel" end
  if within(t, COLLAR2) and ao <= 4 then return "collar" end
  if within(t, GRIP) then
    if VALLEYS[t] then
      if ao <= 3 then return "valley" end
    elseif ao <= 4 then return "rib" end
  end
  if within(t, COLLAR1) and ao <= 4 then return "collar" end
  if within(t, GUARD) then
    local d = (t - GUARD_T0) / GUARD_AT
    if ao <= GUARD_AS * math.sqrt(1 - d * d) then return "guard" end
  end
  if within(t, PLATE) and ao <= 8 then return "plate" end
  if t >= TIP_T and t <= BLADE_END and ao <= math.min(BLADE_HW, (t - TIP_T) / 5) then
    return "blade"
  end
  return nil
end

local function at(x, y)
  if x < 0 or y < 0 or x >= W or y >= H then return nil end
  return part(x - y, x + y - S0)
end

-- light in (t, o, z): straight from the -o side, towards the viewer
local LO, LZ = -0.6, 0.8
local function lit(nt, ns)
  local nz = math.sqrt(math.max(0, 1 - nt * nt - ns * ns))
  return math.max(0, ns * LO + nz * LZ)
end
local function clamp1(v) return math.max(-1, math.min(1, v)) end
local function pick(ramp, i, cuts, shift)
  local k = #ramp
  for j, c in ipairs(cuts) do if i < c then k = j break end end
  k = math.max(1, math.min(#ramp, k + (shift or 0)))
  return ramp[k]
end

local WOOD_CUTS  = { 0.15, 0.50, 0.90, 0.985 }
local BRASS_CUTS = { 0.20, 0.50, 0.88, 0.985 }
local IVORY_CUTS = { 0.12, 0.45, 0.86 }

-- hand-placed blade glints, keyed by (t, o)
local GLINT = {}
local function key(t, o) return t * 1000 + o end
for _, p in ipairs({
  {5,0},{7,0},{9,0},{11,0},   -- ridge glint near the guard
  {3,-4},{5,-4},              -- lit edge glint
  {-21,-4},                   -- small spark mid-blade
}) do GLINT[key(p[1], p[2])] = true end

px.buildFn("gladius", W, H, function(x, y)
  local name = at(x, y)
  if not name then return nil end
  local t, o = x - y, x + y - S0

  -- outline: any 4-neighbour outside the silhouette (selective: lighter where lit)
  local nx, ny, edge = 0, 0, false
  for _, d in ipairs({ {-1,0},{1,0},{0,-1},{0,1} }) do
    if not at(x + d[1], y + d[2]) then nx, ny, edge = nx + d[1], ny + d[2], true end
  end
  if edge then
    if -(nx + ny) > 0 then                  -- outline faces the light
      if name == "blade" then return C.slate_dark end
      if name == "pommel" or name == "guard" then return C.umber end
      if name == "rib" or name == "valley" then return C.dusk end
      return C.terracotta                   -- brass
    end
    return C.plum_dark
  end

  if name == "blade" then
    -- diamond section: lit upper face sky, ridge = hard edge, lower face slate
    if GLINT[key(t, o)] then return C.bone end
    if o <= 0 then
      return C.sky
    end
    local darkEdge = not at(x + 1, y + 1) or not at(x + 2, y) or not at(x, y + 2)
    if darkEdge then return C.slate_dark end
    return C.slate
  end

  if name == "pommel" then
    return pick(WOOD, lit((t - POM_T) / POM_AT, o / POM_AS), WOOD_CUTS)
  end
  if name == "guard" then
    return pick(WOOD, lit((t - GUARD_T0) / GUARD_AT * 0.8, o / GUARD_AS), WOOD_CUTS)
  end
  if name == "rib" then return pick(IVORY, lit(0, clamp1(o / 4.5)), IVORY_CUTS) end
  if name == "valley" then return pick(IVORY, lit(0, clamp1(o / 4.5)), IVORY_CUTS, -1) end
  -- brass: plate, collars, nut (cylinders)
  local hw = (name == "plate") and 8.5 or (name == "nut") and 2.5 or 4.5
  return pick(BRASS, lit(0, clamp1(o / hw)), BRASS_CUTS)
end)
