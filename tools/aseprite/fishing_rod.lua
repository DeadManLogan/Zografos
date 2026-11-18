-- 64x64 old fishing rod, item illustration (posted to Twitter).
-- 45-degree pose: butt bottom-left, tip top-right; light from the top-left,
-- i.e. perpendicular to the rod. A line hangs from the tip with a float + hook.
--
-- References (attribute taken):
--   fishing_rod_01 (watercolour) -> layout of a vintage fly rod: cork butt knob,
--                                   brass reel seat, cigar cork grip, silk wraps,
--                                   perforated brass reel hanging off the seat
--   fishing_rod_02 (photo)       -> natural golden cane colour, hanging line
--                                   with a float, thin metal guides
-- Transformation: the two rods merged into one; reel and float exaggerated so
-- they read at 1:1; the watercolour's warm sepia mood mapped onto Waldgeist's
-- muted ramps (tarnished olive brass, khaki cork, golden-brown cane).
--
-- Geometry in diagonal coordinates (pixel-clean 45-degree lines):
--   t = (x - y + 58) / 2   along the axis, grows towards the tip
--   u = x + y - 58         across the axis, negative = lit (top-left) side
local px = dofile("tools/aseprite/lib/pixel.lua")
local C = px.use("waldgeist")

local W, H = 64, 64

-- Waldgeist ramps (luma in brackets)
local CANE  = { hl = C.c01, base = C.c02, shade = C.c03, deep = C.c05 } -- a6884a(54) 906c30(44) 825337(37) 66352e(26)
local CORK  = { hl = C.c22, base = C.c23, shade = C.c24, deep = C.c28 } -- bdbbae(73) af9e94(63) 907c75(51) 696353(39)
local BRASS = { spec = C.c21, hl = C.c01, base = C.c35, shade = C.c33, deep = C.c09 } -- e3ddd1 a6884a 727234(42) 57562a(32) 323230(20)
local SILK  = { hl = C.c03, base = C.c04, shade = C.c07 }               -- 825337 83473d 612638
local OUTLINE = C.c11                                                    -- 382d35, purple-brown dark

-- axial layout: { t0, t1, material, uLo, uHi }
local SEGS = {
  { 3,  3,  "cork",  -1, 1 },  -- rounded butt knob
  { 4,  6,  "cork",  -2, 2 },
  { 7,  7,  "brass", -2, 2 },  -- reel seat ring
  { 8,  13, "brass", -1, 1 },  -- reel seat
  { 14, 14, "brass", -2, 2 },  -- reel seat ring
  { 15, 25, "cork",  -2, 2 },  -- cigar grip
  { 26, 28, "cork",  -1, 1 },
  { 29, 29, "brass", -1, 1 },  -- winding check
  { 30, 41, "cane",  -1, 1 },
  { 42, 43, "brass", -1, 1 },  -- ferrule
  { 44, 50, "cane",  -1, 0 },
  { 51, 55, "cane",   0, 0 },
  { 56, 56, "tip",    0, 0 },  -- tip-top
}
local WRAPS  = { [34] = true, [39] = true, [46] = true, [52] = true }
local GUIDES = { 34, 46, 52 }

-- shade per across-axis line, lit side first
local SHADE = {
  cane  = { [3] = { CANE.hl, CANE.base, CANE.shade }, [2] = { CANE.hl, CANE.base }, [1] = { CANE.base } },
  cork  = { [5] = { CORK.base, CORK.hl, CORK.base, CORK.base, CORK.shade }, [3] = { CORK.hl, CORK.base, CORK.shade } },
  brass = { [5] = { BRASS.base, BRASS.hl, BRASS.base, BRASS.shade, BRASS.deep }, [3] = { BRASS.hl, BRASS.base, BRASS.shade } },
  silk  = { [3] = { SILK.base, SILK.shade, SILK.shade }, [2] = { SILK.base, SILK.shade }, [1] = { SILK.shade } },
  tip   = { [1] = { C.c19 } },
}
-- lit-side outline = darkest tone of the neighbouring material (selective outline)
local LIT_OUTLINE = { cane = C.c08, silk = C.c08, cork = CORK.deep, brass = CORK.deep,
                      reel = CORK.deep, float = C.c06, tip = OUTLINE }

-- canvas: col[y][x] = hex, mat[y][x] = material name (interior only)
local col, mat = {}, {}
for y = 0, H - 1 do col[y] = {}; mat[y] = {} end
local function put(x, y, m, c)
  if x >= 0 and x < W and y >= 0 and y < H then mat[y][x] = m; col[y][x] = c end
end

-- 1. rod
for y = 0, H - 1 do
  for x = 0, W - 1 do
    local t = math.floor((x - y + 58) / 2)
    local u = x + y - 58
    for _, s in ipairs(SEGS) do
      if t >= s[1] and t <= s[2] and u >= s[4] and u <= s[5] then
        local m = s[3]
        if m == "cane" and WRAPS[t] then m = "silk" end
        local n = s[5] - s[4] + 1
        put(x, y, m, SHADE[m][n][u - s[4] + 1])
      end
    end
  end
end

-- 2. reel: face-on perforated brass disc hanging off the reel seat
local RX, RY = 18, 54
local SQ2 = math.sqrt(2)
for y = RY - 7, RY + 7 do
  for x = RX - 7, RX + 7 do
    local dx, dy = x - RX, y - RY
    local d = math.sqrt(dx * dx + dy * dy)
    if d <= 6.5 then
      local f = d > 0 and (-dx - dy) / (d * SQ2) or 0   -- >0 faces the top-left light
      local c
      if d > 5.6 then                                      -- outer rim
        if f > 0.92 then c = BRASS.spec
        elseif f > 0.45 then c = BRASS.hl
        elseif f > -0.35 then c = BRASS.base
        else c = BRASS.shade end
      elseif d > 4.6 then                                  -- inner rim / groove
        c = (f > 0.2) and BRASS.deep or BRASS.shade
      else                                                 -- face plate
        c = BRASS.base
        if f < -0.5 and d > 2.9 then c = BRASS.shade end
      end
      put(x, y, "reel", c)
    end
  end
end
-- perforations, spindle
for i = 0, 5 do
  local a = math.rad(30 + i * 60)
  put(RX + math.floor(3.2 * math.cos(a) + 0.5), RY + math.floor(3.2 * math.sin(a) + 0.5), "reel", C.c14)
end
put(RX, RY, "reel", BRASS.spec)
put(RX - 1, RY, "reel", BRASS.hl)
put(RX, RY + 1, "reel", BRASS.shade)
-- reel foot bridging seat and reel
for _, p in ipairs({ { 11, 49 }, { 12, 48 }, { 12, 49 }, { 13, 48 }, { 12, 50 }, { 13, 49 } }) do
  put(p[1], p[2], "brass", BRASS.base)
end

-- 3. float (red top, cream bottom), hanging below the tip
local FLOAT = {
  { 29, 56, { C.c23, SILK.base, SILK.base } },
  { 30, 56, { SILK.base, SILK.base, SILK.shade } },
  { 31, 56, { C.c21, C.c22, C.c23 } },
  { 32, 57, { C.c23 } },
}
for _, r in ipairs(FLOAT) do
  for i, c in ipairs(r[3]) do put(r[2] + i - 1, r[1], "float", c) end
end

-- 4. outline pass (4-neighbour; lit side = top/left of the interior)
local function inside(x, y) return x >= 0 and x < W and y >= 0 and y < H and mat[y][x] ~= nil end
local out = {}
for y = 0, H - 1 do
  out[y] = {}
  for x = 0, W - 1 do
    if not inside(x, y) then
      local lit  = (inside(x + 1, y) and 1 or 0) + (inside(x, y + 1) and 1 or 0)
      local dark = (inside(x - 1, y) and 1 or 0) + (inside(x, y - 1) and 1 or 0)
      if lit + dark > 0 then
        local m = mat[y][x + 1] or mat[y + 1] and mat[y + 1][x] or mat[y][x - 1] or (y > 0 and mat[y - 1][x])
        out[y][x] = (lit > dark) and LIT_OUTLINE[m] or OUTLINE
      end
    end
  end
end
for y = 0, H - 1 do for x = 0, W - 1 do if out[y][x] then col[y][x] = out[y][x] end end end

-- 4b. age: pits in the cork, verdigris on the brass, a darker grip where hands held it
local AGE = {
  { 6, 51, CORK.shade }, { 18, 39, CORK.shade }, { 21, 37, CORK.shade }, { 24, 32, CORK.shade },
  { 17, 42, CORK.shade }, { 26, 32, CORK.shade }, { 20, 36, CORK.deep }, { 23, 35, CORK.shade },
  { 22, 58, C.c37 }, { 23, 57, C.c38 }, { 21, 59, C.c38 }, { 14, 45, C.c37 },
}
for _, p in ipairs(AGE) do if mat[p[2]][p[1]] then col[p[2]][p[1]] = p[3] end end

-- 5. overlays without outline: guides, line, hook
for _, g in ipairs(GUIDES) do
  -- stub sticking out of the shadow side, perpendicular to the rod
  local hi
  for _, s in ipairs(SEGS) do if g >= s[1] and g <= s[2] then hi = s[5] end end
  for k = 2, 3 do
    local u = hi + k
    local x = (2 * g - 58 + u + 58 + ((u % 2 == 0) and 0 or 1)) // 2
    local y = 58 + u - x
    col[y][x] = (k == 2) and C.c12 or C.c19
  end
end
local LINE = C.c22
for y = 2, 27 do col[y][57] = LINE end
for y = 34, 36 do col[y][57] = LINE end
for _, p in ipairs({ { 57, 37, C.c20 }, { 57, 38, C.c19 }, { 58, 39, C.c18 }, { 59, 38, C.c19 }, { 59, 37, C.c20 } }) do
  col[p[2]][p[1]] = p[3]
end

px.buildFn("fishing_rod", W, H, function(x, y) return col[y][x] end)
