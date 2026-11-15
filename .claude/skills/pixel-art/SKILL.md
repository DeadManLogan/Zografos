---
name: pixel-art
description: Draw, revise or review pixel-art sprites with Aseprite (headless Lua). Use for any request to draw/create/redraw/improve/review a sprite, sprite sheet, animation frame, icon, tile or item in this project.
---

# Pixel art sprites (Aseprite, headless)

## Guides (required reading)
Before planning any sprite or sprite sheet, **read all four guides in this folder** and apply whichever sections fit the subject:
- [`lighting-shading.md`](lighting-shading.md): light direction, bell-curve shade distribution, hard vs. soft edges, specular/rim light, shading clustered forms by depth.
- [`color-ramps.md`](color-ramps.md): hue-shifted ramps from the fixed palette, saturation placement, bridge colours, palette luma table.
- [`references-and-forms.md`](references-and-forms.md): reference lists and transformation, silhouette → structure → masses → detail, orphan pixels, selective outlines, grass.
- [`readability-and-contrast.md`](readability-and-contrast.md): signal vs. noise (characters/items vs. terrain), silhouette test, low-contrast detail for ground tiles, top-down rules, style consistency.

Each guide ends with a checklist. Step 5's critique must go through every applicable checklist item.

## Workflow
1. **Plan before pixels.** Write down: canvas size, role (`signal` or `ground`, see `readability-and-contrast.md`), silhouette (width of the shape per row), light direction, the 3–5 palette ramps you will use (from `color-ramps.md`), the references with the attribute taken from each plus the transformation (`references-and-forms.md`), and what makes the object *recognisable* at 1:1 (e.g. amphora = narrow neck + two handles + egg body + foot).
2. **Write the script** `tools/aseprite/<name>.lua` as a character grid (one string per row, `.` = transparent) plus a legend mapping chars to palette names, and call the shared helper:
   ```lua
   local px = dofile("tools/aseprite/lib/pixel.lua")
   local C = px.C
   local legend = { K = C.plum_dark, O = C.ochre }
   local rows = { "....KK....", ... }
   px.build("<name>", rows, legend)   -- -> assets/sprites/<name>.aseprite/.png + previews/<name>_preview.png
   ```
   The helper rejects wrong row lengths, unknown chars and non-palette colours, so mistakes never export. Comment each row (`-- 7 belly (widest)`) so later edits stay easy.
   **Large sprites (32×32 and up):** hand-typed grids get error-prone. Use `px.buildFn(name, w, h, fn)` instead, where `fn(x, y)` returns a palette hex or nil. Build the base from geometry (distance from centre, a surface normal dotted with the light, then snapped to a ramp with thresholds). Layer hand-placed detail on top as small `{x, y, offset}` tables that shift a pixel up or down its ramp: rivets, bevels, scratches, dents. See `tools/aseprite/spartan_shield.lua`. Lessons learned there:
   - Emblems and inlays should be a **flat colour with 1px bevels** (lit edge +1, shadow edge −1). If they follow the dome lighting, they split into two colours and look broken.
   - Keep dome shading gentle. Strong normals give hard diagonal bands that read as facets.
   - Damage reads best as a *story* (parallel blade scratches, one rim dent), not as scattered blobs.
3. **Run it synchronously** from the repo root (PowerShell):
   `& "C:\Program Files\Aseprite\Aseprite.exe" -b --script tools/aseprite/<name>.lua | Out-Null`
   Aseprite.exe is a GUI-subsystem app: without `| Out-Null` (or `Start-Process -Wait`) PowerShell returns *before* the files are written and you will review a stale image. `print()` output is not shown in batch mode.
4. **Review** `previews/<name>_preview.png` with the Read tool. It shows a zoom on a checkerboard, a 4x copy, and 1:1 copies on mid (slate), light (bone) and dark (ink) backgrounds. Judge the 1:1 copies first: is the silhouette readable on all three? For the bell-curve check, read `previews/<name>_stats.txt` (pixels and % per palette colour).
5. **Critique in writing, then revise.** Go through the guide checklists, then list concrete problems with row/column refs, fix them, re-render. Do at least one improvement pass (more if asked). To keep versions for comparison, copy the preview to `previews/<name>_vN.png`.

## Art rules
- **Palette only.** Use `px.C.<name>` (names in `lib/pixel.lua`). Never invent hex values.
- **Silhouette first.** Get the outline shape right before shading. Proportions sell the object: exaggerate the defining feature (an amphora's neck is taller and narrower than you'd think).
- **Outline:** 1px, using `plum_dark` (#39202e) rather than pure black, so `ink` (#17111a) stays available for black-figure/glaze details. Dark areas may merge with the outline; that's fine.
- **Light from the top-left.** Each material gets a ramp of highlight → base → shade → deep shade. Put highlights a pixel *inside* the left edge, not on it; put the darkest shade on the right edge and the underside.
- **Curved highlights.** On round forms, step the highlight diagonally (an arc), not as a straight vertical stripe.
- **No pillow shading** (shade following the outline on every side equally).
- **Watch for accidental faces.** Two symmetric dark marks above a horizontal dark band read as eyes and a mouth. Break symmetry or remove them.
- **Detail budget at 16×16:** decorations of 1px dots/teeth often read as noise or faces. Prefer one or two clean bands and solid colour fields, and spend pixels on shape and light.
- **Thin parts (handles, straps):** 1px lines with a clear transparent hole read better than chunky 2px blocks.
- **Avoid orphan pixels and jaggies:** curves should step in consistent runs (e.g. 3-2-1), not 1-3-1.

## Material ramps
See the hue-shifted ramp table in [`color-ramps.md`](color-ramps.md). That is the single source for ramps, so add new materials there.

## Sprite sheets
Every frame and every sprite on a sheet must share the same rules: one light direction, the same ramps per material, the same outline colour, the same shade distribution and the same detail "brush". Plan these once for the whole sheet, then check each frame against them in the critique. Review the sheet at 1:1 side by side: a frame that pops out (brighter, more detailed, different outline) is a bug.

**Animation file structure** (from Adam C. Younis, "Tips & Scripts for Supercharging Your Aseprite Workflow"):
- **One `.aseprite` file per character** holding all of its animations, so scale, colours and timing stay comparable.
- **One Aseprite tag per animation** (`idle`, `run`, `jump`, `attack`…). A looping animation must be one tag so it can be previewed looping last → first.
- **One layer per body part / element, named** (`torso`, `arm_front`, `head`…). This allows non-destructive edits and recolouring a part across every frame at once.
- **Export one PNG strip per tag** (`assets/sprites/<name>_<tag>.png`), never one combined sheet sliced by index. Adding a frame to one animation would shift every later frame's index and break the engine's references.
- **Block out first:** draft animations as rough coloured silhouettes per body part, check timing and poses (test in game if possible), and only then render final pixels.
- Non-exported helper layers (scale references, background context) stay **locked or hidden** and are skipped on export.
- Note: `lib/pixel.lua` currently builds single-frame, single-layer sprites. Multi-frame/tag/layer support has to be added to the helper before the first animated sheet.

## Files
- `.claude/skills/pixel-art/*.md`: this skill and its guides.
- `tools/aseprite/lib/pixel.lua`: palette, grid → sprite, save, preview.
- `tools/aseprite/<name>.lua`: one script per sprite.
- `assets/sprites/`: deliverables (`.aseprite` + `.png`).
- `previews/`: review images (git-ignored).
