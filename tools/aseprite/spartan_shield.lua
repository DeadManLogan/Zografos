-- 64x64 Spartan hoplite shield (aspis), inventory item.
-- Front view. Slim rounded bronze rim, painted wine dome, raised bronze lambda.
--
-- References (attribute taken):
--   real hoplite aspis      -> round silhouette, slim rolled bronze rim (~5% of diameter)
--   red-painted shields     -> colour mood: deep red field, bronze trim
--   Lakedaimonian lambda    -> the emblem
-- Transformation: stylised front view; lambda exaggerated into a raised
-- bronze inlay so it reads at 1:1 in the inventory.
local px = dofile("tools/aseprite/lib/pixel.lua")
local C = px.use("herbs_n_spices")

local W, H = 64, 64
local CX, CY = 32, 32
local R_OUT    = 31    -- silhouette radius (outer 1px = outline)
local R_RIM_IN = 27    -- inner edge of the bronze rim (rim = 3px)
local R_GROOVE = 26    -- 1px dark seam between face and rim

-- light from top-left, towards the viewer
local function norm(x, y, z) local l = math.sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
local LX, LY, LZ = norm(-0.55, -0.75, 0.9)

-- ramps, dark -> light (hue-shifted: cool purple at the bottom, warm at the top)
local BRONZE = { C.plum_dark, C.umber, C.terracotta, C.ochre, C.sand, C.bone }
local WINE   = { C.plum_dark, C.wine, C.terracotta }

local function pick(ramp, i, cuts)
  for k, c in ipairs(cuts) do if i < c then return k end end
  return #ramp
end
local RIM_CUTS  = { 0.15, 0.40, 0.66, 0.90, 0.985 }
local WINE_CUTS = { 0.33, 0.90 }  -- thin deep-shade crescent, wine dominant

local function shade(nr, ux, uy)
  local nz = math.sqrt(math.max(0, 1 - nr*nr))
  return math.max(0, nr*ux*LX + nr*uy*LY + nz*LZ)
end

local function polar(x, y)
  local dx, dy = x + 0.5 - CX, y + 0.5 - CY
  local d = math.sqrt(dx*dx + dy*dy)
  if d == 0 then return 0, 0, 0 end
  return d, dx/d, dy/d
end

local function segDist(x, y, ax, ay, bx, by)
  local vx, vy = bx-ax, by-ay
  local t = ((x-ax)*vx + (y-ay)*vy) / (vx*vx + vy*vy)
  t = math.max(0, math.min(1, t))
  local qx, qy = ax + t*vx - x, ay + t*vy - y
  return math.sqrt(qx*qx + qy*qy)
end

-- lambda: two strokes from the apex, top and feet cut flat
local APX, APY = 32, 11
local FOOT_Y = 49.5
local function inLambda(x, y)
  local fx, fy = x + 0.5, y + 0.5
  if fy > FOOT_Y or fy < APY - 1.5 then return false end
  local w = 3.2
  return segDist(fx, fy, APX, APY, 17.5, FOOT_Y + 2) < w
      or segDist(fx, fy, APX, APY, 46.5, FOOT_Y + 2) < w
end

-- hand-placed wear on the paint: ramp offsets
local WEAR = {}
local function mark(list, v) for _, p in ipairs(list) do WEAR[p[2] * W + p[1]] = v end end
-- two parallel blade scratches, upper right
mark({ {41,18},{42,19},{43,19},{44,20},{45,21},{46,22},{47,22} }, 1)
mark({ {44,25},{45,26},{46,26},{47,27},{48,28} }, 1)
-- small scuffs
mark({ {17,31},{18,30},{19,30} }, 1)
mark({ {38,42},{39,43} }, 1)

-- one dent in the lower-left rim
local DENT = {}
for _, p in ipairs({ {12,51,-2},{11,51,-1},{12,52,-1},{13,52,1} }) do DENT[p[2] * W + p[1]] = p[3] end

local function clamp(i, n) return math.max(1, math.min(n, i)) end

px.buildFn("spartan_shield", W, H, function(x, y)
  local d, ux, uy = polar(x, y)
  if d >= R_OUT then return nil end

  if d >= R_OUT - 1 then                                 -- selective outline
    local facing = ux * LX + uy * LY                     -- >0 = edge faces the light
    if facing > 0.45 then return C.umber end
    if facing > -0.2 then return C.plum_dark end
    return C.ink
  end

  if d >= R_RIM_IN then                                  -- rolled bronze rim
    local t = (d - R_RIM_IN) / (R_OUT - 1 - R_RIM_IN)
    local nr = -math.cos(math.pi * t) * 0.8
    local k = pick(BRONZE, shade(nr, ux, uy), RIM_CUTS)
    k = k + (DENT[y * W + x] or 0)
    return BRONZE[clamp(k, #BRONZE)]
  end

  if d >= R_GROOVE then return C.plum_dark end           -- seam

  if inLambda(x, y) then                                 -- raised bronze inlay
    local k = 4                                          -- flat ochre
    if not inLambda(x - 1, y - 1) then k = k + 1 end     -- lit bevel
    if not inLambda(x + 1, y + 1) then k = k - 1 end     -- shadow bevel
    return BRONZE[clamp(k, #BRONZE)]
  end

  local i = shade((d / R_GROOVE) * 0.45, ux, uy)         -- gentle dome
  local k = pick(WINE, i, WINE_CUTS)
  if inLambda(x - 1, y - 1) then k = k - 1 end           -- lambda cast shadow
  k = k + (WEAR[y * W + x] or 0)
  return WINE[clamp(k, #WINE)]
end)
