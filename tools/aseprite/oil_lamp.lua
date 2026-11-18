-- 64x64 Roman terracotta oil lamp (SKAVO artifact). Palette: waldgeist.
-- Slight 3/4 view from above, side-on: nozzle right, ring handle left (back).
--
-- References (attribute taken):
--   Loeschcke type VIII lamps   -> round bun body, short rounded nozzle, ring handle, rosette discus
--   museum catalog photography  -> calm 3/4 view from above, single soft key light top-left
--   excavated lamps             -> soot-blackened nozzle, dirt in the recesses (the "used" story)
-- Transformation: nozzle and handle exaggerated (longer, thicker) so they read at 1:1.
--
-- Method: the lamp is a small signed-distance model, ray-marched orthographically,
-- shaded with one light, then snapped to palette ramps. Detail (rosette, soot,
-- outline) is applied in a second, screen-space pass. Re-rendering the same model
-- with different dials (ramp length, outline rule, elevation) is how we'll
-- compare styles later.
local px = dofile("tools/aseprite/lib/pixel.lua")
local C = px.use("waldgeist")

---------------------------------------------------------------- style dials
local ELEV   = math.rad(46)          -- camera elevation above the horizon
local LIGHT  = { -0.55, 0.8, -0.1 }  -- screen top-left (slightly from behind)  -- world light dir (x right, y up, z to viewer)
local AMBIENT = 0.12

-- clay ramp, dark -> light (cool/red at the bottom, warm/yellow at the top)
local CLAY = { C.c06, C.c05, C.c04, C.c03, C.c01, C.c23 }
local CLAY_CUTS = { 0.08, 0.24, 0.48, 0.84, 0.97 }  -- intensity -> ramp index
local SOOT = { C.c09, C.c08 }                      -- heavy -> light soot
local HOLE_DEEP, HOLE_LIP = C.c15, C.c14
local OUT_LIT, OUT_MID, OUT_DARK = C.c06, C.c11, C.c14

---------------------------------------------------------------- vector helpers
local sqrt, max, min, abs = math.sqrt, math.max, math.min, math.abs
local function len2(a, b) return sqrt(a*a + b*b) end
local function len3(a, b, c) return sqrt(a*a + b*b + c*c) end
local function norm3(v) local l = len3(v[1], v[2], v[3]) return { v[1]/l, v[2]/l, v[3]/l } end
local L = norm3(LIGHT)
local function smin(a, b, k)
  local h = max(k - abs(a - b), 0) / k
  return min(a, b) - h*h*k*0.25
end

---------------------------------------------------------------- the model
-- units = pixels. y up. Lamp axis along x (nozzle +x).
local YC      = 6.0     -- body centre height
local R_BODY  = 18.0
local HH      = 5.5     -- body half height
local RB      = 4.5     -- body edge rounding
local Y_TOP   = YC + HH
local R_DISC  = 11.0    -- sunken discus radius
local DISC_D  = 1.4     -- discus depth
local R_FILL  = 1.9     -- filling hole
local WICK_X, R_WICK = 27.0, 2.1
local HANDLE  = { x = -20.5, y = YC + 4.5, R = 4.8, r = 1.8 }

local function sdBody(x, y, z)
  local qx = len2(x, z) - (R_BODY - RB)
  local qy = abs(y - YC) - (HH - RB)
  return min(max(qx, qy), 0) + len2(max(qx, 0), max(qy, 0)) - RB
end

local function sdRoundCone(x, y, z, ax, ay, r1, bx, by, r2)
  -- capsule with linear radius between a and b (both at z = 0)
  local vx, vy = bx - ax, by - ay
  local t = ((x - ax)*vx + (y - ay)*vy) / (vx*vx + vy*vy)
  t = max(0, min(1, t))
  local cx, cy = ax + t*vx, ay + t*vy
  return len3(x - cx, y - cy, z) - (r1 + (r2 - r1)*t)
end

local function sdNozzle(x, y, z)
  local d = sdRoundCone(x, y, z, 9, YC + 0.8, 6.2, WICK_X + 1.0, YC + 1.6, 4.4)
  return max(d, y - (Y_TOP - 0.4))       -- flat top, flush with the shoulder
end

local function sdHandle(x, y, z)
  local qx = len2(x - HANDLE.x, y - HANDLE.y) - HANDLE.R
  return len2(qx, z) - HANDLE.r
end

-- returns distance, part id
local function sdf(x, y, z)
  local d = smin(sdBody(x, y, z), sdNozzle(x, y, z), 4.0)
  d = smin(d, sdHandle(x, y, z), 1.6)
  -- raised moulding ring around the discus
  local ring = len2(len2(x, z) - (R_DISC + 0.9), y - (Y_TOP - 0.2)) - 0.9
  d = min(d, ring)
  -- sunken discus
  local disc = max(len2(x, z) - R_DISC, (Y_TOP - DISC_D) - y)
  d = max(d, -disc)
  -- filling hole and wick hole
  local fill = len2(x + 1.0, z - 0.5) - R_FILL
  local wick = len2(x - WICK_X, z) - R_WICK
  d = max(d, -fill)
  d = max(d, -wick)
  return d
end

local function partAt(x, y, z)
  if len2(x + 1.0, z - 0.5) < R_FILL + 0.35 and y < Y_TOP - DISC_D + 0.2 then return "hole", Y_TOP - DISC_D - y end
  if len2(x - WICK_X, z) < R_WICK + 0.35 and y < Y_TOP - 0.6 then return "hole", Y_TOP - 0.4 - y end
  if len2(x, z) < R_DISC - 0.1 and y < Y_TOP - DISC_D + 0.3 then return "disc", 0 end
  return "clay", 0
end

local function normalAt(x, y, z)
  local e = 0.04
  return norm3({
    sdf(x + e, y, z) - sdf(x - e, y, z),
    sdf(x, y + e, z) - sdf(x, y - e, z),
    sdf(x, y, z + e) - sdf(x, y, z - e),
  })
end

local function shadowed(x, y, z)
  local t = 0.35
  for _ = 1, 80 do
    local d = sdf(x + L[1]*t, y + L[2]*t, z + L[3]*t)
    if d < 0.02 then return true end
    t = t + max(d, 0.05)
    if t > 45 then break end
  end
  return false
end

---------------------------------------------------------------- pass 1: render
local BW, BH = 96, 96
local se, ce = math.sin(ELEV), math.cos(ELEV)
local DIR = { 0, -se, -ce }          -- camera looks down and into -z
local UP  = { 0, ce, -se }
local CENTER = { 3.0, YC + 2.0, 0 }

local buf = {}
for py = 0, BH - 1 do
  for pxl = 0, BW - 1 do
    local sx, sy = pxl + 0.5 - BW/2, BH/2 - py - 0.5
    local ox = CENTER[1] + sx
    local oy = CENTER[2] + sy*UP[2] - DIR[2]*60
    local oz = CENTER[3] + sy*UP[3] - DIR[3]*60
    local t, hit = 0, false
    for _ = 1, 200 do
      local x, y, z = ox + DIR[1]*t, oy + DIR[2]*t, oz + DIR[3]*t
      local d = sdf(x, y, z)
      if d < 0.01 then hit = true break end
      t = t + d * 0.8
      if t > 140 then break end
    end
    if hit then
      local x, y, z = ox + DIR[1]*t, oy + DIR[2]*t, oz + DIR[3]*t
      local n = normalAt(x, y, z)
      local lit = max(0, n[1]*L[1] + n[2]*L[2] + n[3]*L[3])
      if lit > 0 and shadowed(x, y, z) then lit = lit * 0.25 end
      local part, depth = partAt(x, y, z)
      buf[py * BW + pxl] = { i = AMBIENT + (1 - AMBIENT) * lit, part = part, depth = depth,
                             x = x, y = y, z = z, t = t }
    end
  end
end

-- bounding box -> centre in 64x64
local x0, y0, x1, y1 = BW, BH, -1, -1
for k, _ in pairs(buf) do
  local bx, by = k % BW, k // BW
  x0, y0, x1, y1 = min(x0, bx), min(y0, by), max(x1, bx), max(y1, by)
end
local W, H = 64, 64
local offX = (W - (x1 - x0 + 1)) // 2 - x0
local offY = (H - (y1 - y0 + 1)) // 2 - y0
-- hand fixes: pixels forced transparent before the outline pass (64x64 coords)
local CLEAR = {}
for _, p in ipairs({ {28, 17}, {29, 17} }) do CLEAR[p[2] * 64 + p[1]] = true end  -- bump on the back rim

local function cell(x, y)   -- x, y in final 64x64 space
  if CLEAR[y * 64 + x] then return nil end
  local bx, by = x - offX, y - offY
  if bx < 0 or by < 0 or bx >= BW or by >= BH then return nil end
  return buf[by * BW + bx]
end

---------------------------------------------------------------- pass 2: colour
local function rampIndex(i, cuts)
  for k, c in ipairs(cuts) do if i < c then return k end end
  return #cuts + 1
end
local function clamp(k, n) return max(1, min(n, k)) end

-- rosette petals on the discus floor (world xz polar coords)
local PETALS = 6
local function petal(c)
  if not c or c.part ~= "disc" then return false end
  local x, z = c.x + 0.0, c.z
  local r = len2(x, z)
  if r < 3.6 or r > 9.6 then return false end
  local th = math.atan(z, x) + math.pi / PETALS
  local seg = 2 * math.pi / PETALS
  local phi = (th % seg) - seg / 2
  local w = 0.7 + 2.4 * math.sin(math.pi * (r - 3.6) / 6.0)
  return abs(phi) * r < w
end

-- soot around the wick hole: amount 0..1 from world distance, with a fixed jitter
local function sootAmount(c)
  if c.part == "hole" then return 0 end
  local dx, dz = c.x - WICK_X, c.z
  local d = len2(dx * 0.85, dz * 1.15)
  local jitter = ((math.floor(c.x * 1.7) * 7 + math.floor(c.z * 1.3) * 13) % 5) * 0.25
  return max(0, min(1, (4.6 + jitter - d) / 2.5))
end

local function colourAt(x, y)
  local c = cell(x, y)
  if not c then return nil end

  -- selective outline on the silhouette
  local n = { cell(x - 1, y), cell(x + 1, y), cell(x, y - 1), cell(x, y + 1) }
  if not (n[1] and n[2] and n[3] and n[4]) then
    local lx, ly = 0, 0                        -- direction toward empty space
    if not n[1] then lx = lx - 1 end
    if not n[2] then lx = lx + 1 end
    if not n[3] then ly = ly - 1 end
    if not n[4] then ly = ly + 1 end
    local facing = -lx * 0.7 + -ly * 0.7       -- >0: empty side is up/left (lit)
    if facing > 0.3 then return OUT_LIT end
    if facing > -0.3 then return OUT_MID end
    return OUT_DARK
  end

  if c.part == "hole" then
    return (c.depth < 1.2) and HOLE_LIP or HOLE_DEEP
  end

  local k = rampIndex(c.i, CLAY_CUTS)
  if c.part == "disc" then
    if petal(c) then
      k = 4                                    -- flat raised petal
      if not petal(cell(x + 1, y + 1)) then k = 2 end  -- soft shadow edge only
      if c.i < 0.3 then k = k - 1 end          -- in the rim's shadow
    else
      k = min(k, 4) - 2                        -- recessed floor: two steps down so petals read
    end
  end

  local s = sootAmount(c)
  if s > 0.7 then return SOOT[1] end
  if s > 0.4 then return SOOT[2] end
  if s > 0.1 then k = k - 2 end
  return CLAY[clamp(k, #CLAY)]
end

local img = {}
for y = 0, H - 1 do
  for x = 0, W - 1 do img[y * W + x] = colourAt(x, y) end
end

-- clean-up: an interior pixel whose 4 neighbours all share one other colour
-- is an orphan; absorb it.
local OUTLINES = { [OUT_LIT] = true, [OUT_MID] = true, [OUT_DARK] = true }
for y = 1, H - 2 do
  for x = 1, W - 2 do
    local v = img[y * W + x]
    if v and not OUTLINES[v] then
      local a, b, c2, d = img[y*W + x - 1], img[y*W + x + 1], img[(y-1)*W + x], img[(y+1)*W + x]
      if a and a == b and b == c2 and c2 == d and a ~= v and not OUTLINES[a] then
        img[y * W + x] = a
      end
    end
  end
end

px.buildFn("oil_lamp", W, H, function(x, y) return img[y * W + x] end)
