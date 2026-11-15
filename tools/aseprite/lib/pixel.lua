-- Shared helpers for Zografos sprite scripts.
-- Load from a sprite script (run from the repo root):
--   local px = dofile("tools/aseprite/lib/pixel.lua")
--   local C  = px.use("herbs_n_spices")   -- palettes/<id>.gpl

local M = {}

-- Palettes live in palettes/<id>.gpl (GIMP palette format), see
-- palettes/README.md. Pick one per sprite script with px.use("<id>").
M.PALETTE_DIR = "palettes"
M.DEFAULT = "herbs_n_spices"

-- The active palette. Filled by M.use(). Index order matters: it is written
-- into every sprite's palette in this order.
M.PALETTE_ID = nil
M.PALETTE = {}  -- array of { name = "ochre", hex = "#c98d3f" }
M.C = {}        -- name -> hex (also index -> hex, so C[5] works)

local function hexToRGB(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function luma(hex)
  local r, g, b = hexToRGB(hex)
  return 0.299 * r + 0.587 * g + 0.114 * b
end

local function inPalette(hex)
  hex = hex:lower()
  for _, e in ipairs(M.PALETTE) do
    if e.hex == hex then return true end
  end
  return false
end

local function abs(path)
  if app.fs.isFile(path) or path:match("^%a:[/\\]") or path:sub(1, 1) == "/" then
    return path
  end
  return app.fs.joinPath(app.fs.currentPath, path)
end

-- Ids of all palettes in palettes/, sorted.
function M.list()
  local ids = {}
  for _, f in ipairs(app.fs.listFiles(abs(M.PALETTE_DIR))) do
    local id = f:match("^(.+)%.gpl$")
    if id then ids[#ids + 1] = id end
  end
  table.sort(ids)
  return ids
end

-- Parse a .gpl file into { {name=, hex=}, ... }.
local function loadGpl(path)
  local f = io.open(path, "r")
  if not f then
    error(("palette file not found: %s (available: %s)"):format(path, table.concat(M.list(), ", ")))
  end
  local entries, seen, n = {}, {}, 0
  for line in f:lines() do
    line = line:gsub("\r$", "")
    local r, g, b, name = line:match("^%s*(%d+)%s+(%d+)%s+(%d+)%s*(.-)%s*$")
    if r and not line:match("^%s*#") then
      n = n + 1
      r, g, b = tonumber(r), tonumber(g), tonumber(b)
      assert(r <= 255 and g <= 255 and b <= 255, ("%s: colour %d out of range: %s"):format(path, n, line))
      name = name:lower():gsub("%s+", "_")
      -- unnamed, or named by its own hex code (Lospec exports) -> c01, c02...
      if name == "" or name == "untitled" or name:match("^#?%x%x%x%x%x%x$") then
        name = ("c%02d"):format(n)
      end
      assert(not seen[name], ("%s: duplicate colour name '%s'"):format(path, name))
      seen[name] = true
      entries[#entries + 1] = { name = name, hex = ("#%02x%02x%02x"):format(r, g, b) }
    end
  end
  f:close()
  assert(#entries > 0, path .. ": no colours found")
  assert(#entries <= 256, path .. ": more than 256 colours")
  return entries
end

-- Make palettes/<id>.gpl the active palette and return M.C (name -> hex).
-- M.PALETTE and M.C are refilled in place, so older references stay valid.
function M.use(id)
  id = id or M.DEFAULT
  local entries = loadGpl(abs(app.fs.joinPath(M.PALETTE_DIR, id .. ".gpl")))
  for k in pairs(M.PALETTE) do M.PALETTE[k] = nil end
  for k in pairs(M.C) do M.C[k] = nil end
  for i, e in ipairs(entries) do
    M.PALETTE[i] = e
    M.C[e.name] = e.hex
    M.C[i] = e.hex
  end
  M.PALETTE_ID = id
  return M.C
end

-- Preview backgrounds for the active palette: darkest, lightest, and the
-- colour closest to mid-grey brightness.
local function backgrounds()
  local dark, light, mid = M.PALETTE[1].hex, M.PALETTE[1].hex, M.PALETTE[1].hex
  for _, e in ipairs(M.PALETTE) do
    local l = luma(e.hex)
    if l < luma(dark) then dark = e.hex end
    if l > luma(light) then light = e.hex end
    if math.abs(l - 128) < math.abs(luma(mid) - 128) then mid = e.hex end
  end
  return mid, light, dark
end

M.use(M.DEFAULT)

-- Validate a grid + legend. Errors loudly so mistakes never get exported.
local function validate(rows, legend, w, h)
  assert(#rows == h, ("grid has %d rows, expected %d"):format(#rows, h))
  for y, row in ipairs(rows) do
    assert(#row == w, ("row %d has %d chars, expected %d: '%s'"):format(y - 1, #row, w, row))
    for x = 1, #row do
      local ch = row:sub(x, x)
      assert(ch == "." or legend[ch], ("row %d col %d: char '%s' not in legend"):format(y - 1, x - 1, ch))
    end
  end
  for ch, hex in pairs(legend) do
    assert(inPalette(hex), ("legend '%s' = %s is not in palette '%s'"):format(ch, hex, M.PALETTE_ID))
  end
end

-- Build a sprite from a character grid.
--   rows   : array of strings, one per pixel row; '.' = transparent
--   legend : { char = "#rrggbb" } (must be palette colours)
function M.fromGrid(rows, legend)
  local h, w = #rows, #rows[1]
  validate(rows, legend, w, h)

  local spr = Sprite(w, h, ColorMode.RGB)
  local pal = Palette(#M.PALETTE)
  for i, e in ipairs(M.PALETTE) do
    local r, g, b = hexToRGB(e.hex)
    pal:setColor(i - 1, Color { r = r, g = g, b = b, a = 255 })
  end
  spr:setPalette(pal)

  local img = spr.cels[1].image
  local pc = app.pixelColor
  for y, row in ipairs(rows) do
    for x = 1, #row do
      local ch = row:sub(x, x)
      if ch ~= "." then
        local r, g, b = hexToRGB(legend[ch])
        img:drawPixel(x - 1, y - 1, pc.rgba(r, g, b, 255))
      end
    end
  end
  return spr
end

-- Build a sprite from a function. fn(x, y) returns a palette hex or nil
-- (transparent). Use for larger sprites whose base is geometric (circles,
-- shading from a normal), then layer hand-placed detail inside fn.
function M.fromFunction(w, h, fn)
  local grid = {}
  local legend, rev, nextCh = {}, {}, 1
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  for y = 0, h - 1 do
    local row = {}
    for x = 0, w - 1 do
      local hex = fn(x, y)
      if hex then
        hex = hex:lower()
        if not rev[hex] then
          local ch = chars:sub(nextCh, nextCh); nextCh = nextCh + 1
          rev[hex] = ch; legend[ch] = hex
        end
        row[#row + 1] = rev[hex]
      else
        row[#row + 1] = "."
      end
    end
    grid[#grid + 1] = table.concat(row)
  end
  return M.fromGrid(grid, legend)
end

function M.buildFn(name, w, h, fn, opts)
  opts = opts or {}
  local spr = M.fromFunction(w, h, fn)
  M.save(spr, opts.dir or "assets/sprites", name)
  local pdir = opts.previewDir or "previews"
  M.preview(spr, pdir .. "/" .. name .. "_preview.png", opts.scale or 8)
  M.stats(spr, pdir .. "/" .. name .. "_stats.txt")
  return spr
end

-- Save <dir>/<name>.aseprite and <dir>/<name>.png
function M.save(spr, dir, name)
  local base = app.fs.joinPath(abs(dir), name)
  spr:saveAs(base .. ".aseprite")
  spr:saveCopyAs(base .. ".png")
  print("saved " .. base .. ".aseprite / .png")
end

-- Write an enlarged review image: the sprite at `scale` on a checkerboard
-- (so transparency is visible), next to a 1:1 and a 4x copy on a mid-tone
-- background to judge silhouette at real size.
function M.preview(spr, path, scale)
  scale = scale or 16
  local src = Image(spr.width, spr.height, ColorMode.RGB)
  src:drawSprite(spr, 1)
  local w, h = spr.width, spr.height
  local pad = 8
  local smallScale = 4
  local W = w * scale + pad * 4 + w * smallScale + w
  local H = math.max(h * scale, h * smallScale) + pad * 2
  local out = Image(W, H, ColorMode.RGB)
  local pc = app.pixelColor
  local function solid(hex) local r, g, b = hexToRGB(hex) return pc.rgba(r, g, b, 255) end
  local midHex, lightHex, darkHex = backgrounds()
  local bg = solid(midHex)
  out:clear(bg)

  local c1, c2 = pc.rgba(200, 200, 200, 255), pc.rgba(150, 150, 150, 255)
  -- back: nil = checkerboard, otherwise a solid pixel colour
  local function blit(ox, oy, s, back)
    for y = 0, h - 1 do
      for x = 0, w - 1 do
        local v = src:getPixel(x, y)
        local a = pc.rgbaA(v)
        for dy = 0, s - 1 do
          for dx = 0, s - 1 do
            local col
            if a > 0 then
              col = v
            elseif not back then
              col = (((x * s + dx) // 8 + (y * s + dy) // 8) % 2 == 0) and c1 or c2
            else
              col = back
            end
            out:drawPixel(ox + x * s + dx, oy + y * s + dy, col)
          end
        end
      end
    end
  end
  blit(pad, pad, scale, nil)
  blit(pad * 2 + w * scale, pad, smallScale, bg)
  -- 1:1 copies on the palette's mid, lightest and darkest colours:
  -- the sprite must stay readable on all three.
  local x1 = pad * 3 + w * scale + w * smallScale
  local tiles = { bg, solid(lightHex), solid(darkHex) }
  for i, back in ipairs(tiles) do
    local oy = pad + (i - 1) * (h + pad)
    if oy + h <= H then
      for y = oy - 2, oy + h + 1 do
        for x = x1 - 2, x1 + w + 1 do
          if y >= 0 and y < H and x < W then out:drawPixel(x, y, back) end
        end
      end
      blit(x1, oy, 1, back)
    end
  end
  out:saveAs(abs(path))
  print("preview " .. abs(path))
end

-- Write per-colour pixel counts (for the bell-curve check in the critique).
function M.stats(spr, path)
  local src = Image(spr.width, spr.height, ColorMode.RGB)
  src:drawSprite(spr, 1)
  local pc = app.pixelColor
  local counts, total = {}, 0
  for y = 0, spr.height - 1 do
    for x = 0, spr.width - 1 do
      local v = src:getPixel(x, y)
      if pc.rgbaA(v) > 0 then
        local hex = ("#%02x%02x%02x"):format(pc.rgbaR(v), pc.rgbaG(v), pc.rgbaB(v))
        counts[hex] = (counts[hex] or 0) + 1
        total = total + 1
      end
    end
  end
  local lines = { "palette " .. M.PALETTE_ID }
  for _, e in ipairs(M.PALETTE) do
    local n = counts[e.hex]
    if n then lines[#lines + 1] = ("%-11s %s %5d  %5.1f%%"):format(e.name, e.hex, n, 100 * n / total) end
  end
  lines[#lines + 1] = ("total opaque %d"):format(total)
  local f = io.open(abs(path), "w")
  f:write(table.concat(lines, "\n"), "\n")
  f:close()
end

-- Convenience: build, save, preview in one call.
function M.build(name, rows, legend, opts)
  opts = opts or {}
  local spr = M.fromGrid(rows, legend)
  M.save(spr, opts.dir or "assets/sprites", name)
  local pdir = opts.previewDir or "previews"
  M.preview(spr, pdir .. "/" .. name .. "_preview.png", opts.scale or 16)
  M.stats(spr, pdir .. "/" .. name .. "_stats.txt")
  return spr
end

return M
