# Palettes

One palette per file, in GIMP palette format (`.gpl`). The file name without
the extension is the palette's id, e.g. `herbs_n_spices.gpl` → `herbs_n_spices`.

## Adding a palette
Download the **GIMP (.gpl)** version from Lospec (or export one from Aseprite:
palette menu → Save Palette), save it here with a lowercase, underscore name,
and you're done.

Giving each colour a name is optional but recommended, since scripts can then
say `C.ochre` instead of `C.c05`:

```
GIMP Palette
Name: Herbs n Spices
# Mood: warm, earthy, antique
 89  58  49	umber
 57  32  46	plum_dark
```

Each colour line is `R G B` (0–255) followed by an optional name. Names are
lowercased and spaces become `_`. Colours without a name, or whose name is
only a hex code (Lospec's default), are named `c01`, `c02`, … in file order.
A `# Mood: …` comment helps when picking a palette for a new piece.

## Using a palette in a sprite script
```lua
local px = dofile("tools/aseprite/lib/pixel.lua")
local C  = px.use("herbs_n_spices")   -- omit to get the default palette
```

The default is `herbs_n_spices` (`px.DEFAULT` in `tools/aseprite/lib/pixel.lua`).
The palette id is written into each sprite's `previews/<name>_stats.txt`.
