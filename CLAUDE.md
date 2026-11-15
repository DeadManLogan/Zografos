## Pixel art with Aseprite
- Aseprite executable: "C:\Program Files\Aseprite\Aseprite.exe"
- For sprite tasks, follow the `pixel-art` skill (`.claude/skills/pixel-art/SKILL.md`). It covers workflow, art rules and material ramps.
- For sprite tasks: write a Lua script in `tools/aseprite/` using the helper `tools/aseprite/lib/pixel.lua`, then run it headlessly from the repo root and **wait for it** (Aseprite is a GUI exe, so PowerShell won't wait on its own):
  `& "C:\Program Files\Aseprite\Aseprite.exe" -b --script tools/aseprite/<script>.lua | Out-Null`
- Scripts should create/open a sprite, draw with exact pixel coordinates, and save both a `.aseprite` file and a `.png` export to `assets/sprites/`.
- After exporting, open `previews/<name>_preview.png` (zoomed + 1:1) to check the result and fix problems before reporting back. Do at least one improvement pass.
- Palettes live in `palettes/<id>.gpl` (GIMP palette format, one per file, see `palettes/README.md`). Each sprite script picks exactly one with `local C = px.use("<id>")` and uses only its colours. The default is `herbs_n_spices` (Herbs n Spices, 16 colours).
- Choose the palette that fits the piece's mood. If none is named in the request, use the default, or ask when the subject clearly suits another palette in the folder. Never invent colours outside the chosen palette.
