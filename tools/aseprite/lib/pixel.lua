-- Shared helpers for Zografos sprite scripts.
-- Load from a sprite script (run from the repo root):
--   local px = dofile("tools/aseprite/lib/pixel.lua")

local M = {}

-- Herbs n Spices palette (project palette). Index order matters: it is
-- written into every sprite's palette in this order.
M.PALETTE = {
  { name = "umber",      hex = "#593a31" },
  { name = "plum_dark",  hex = "#39202e" },
  { name = "wine",       hex = "#613140" },
  { name = "terracotta", hex = "#83443e" },
  { name = "ochre",      hex = "#c98d3f" },
  { name = "sand",       hex = "#dac282" },
  { name = "olive",      hex = "#9a945c" },
  { name = "moss_grey",  hex = "#6b6657" },
  { name = "slate_dark", hex = "#384150" },
  { name = "slate",      hex = "#6e7e8d" },
  { name = "sky",        hex = "#90b5c6" },
  { name = "bone",       hex = "#f5efe8" },
  { name = "mauve",      hex = "#ab99a4" },
  { name = "dusk",       hex = "#55516f" },
  { name = "aubergine",  hex = "#463554" },
  { name = "ink",        hex = "#17111a" },
}

M.C = {} -- name -> hex
for _, e in ipairs(M.PALETTE) do M.C[e.name] = e.hex end

local function hexToRGB(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
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
    assert(inPalette(hex), ("legend '%s' = %s is not in the project palette"):format(ch, hex))
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
  local bgR, bgG, bgB = hexToRGB(M.C.slate)
  local bg = pc.rgba(bgR, bgG, bgB, 255)
  out:clear(bg)

  local c1, c2 = pc.rgba(200, 200, 200, 255), pc.rgba(150, 150, 150, 255)
  local function solid(hex) local r, g, b = hexToRGB(hex) return pc.rgba(r, g, b, 255) end
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
  -- 1:1 copies on mid (slate), light (bone) and dark (ink) backgrounds:
  -- the sprite must stay readable on all three.
  local x1 = pad * 3 + w * scale + w * smallScale
  local tiles = { bg, solid(M.C.bone), solid(M.C.ink) }
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
  local lines = {}
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
