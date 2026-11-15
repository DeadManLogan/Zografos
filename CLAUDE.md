## Pixel art with Aseprite
- Aseprite executable: "C:\Program Files\Aseprite\Aseprite.exe"
- For sprite tasks, follow the `pixel-art` skill (`.claude/skills/pixel-art/SKILL.md`). It covers workflow, art rules and material ramps.
- For sprite tasks: write a Lua script in `tools/aseprite/` using the helper `tools/aseprite/lib/pixel.lua`, then run it headlessly from the repo root and **wait for it** (Aseprite is a GUI exe, so PowerShell won't wait on its own):
  `& "C:\Program Files\Aseprite\Aseprite.exe" -b --script tools/aseprite/<script>.lua | Out-Null`
- Scripts should create/open a sprite, draw with exact pixel coordinates, and save both a `.aseprite` file and a `.png` export to `assets/sprites/`.
- After exporting, open `previews/<name>_preview.png` (zoomed + 1:1) to check the result and fix problems before reporting back. Do at least one improvement pass.
- Use only the project palette below unless told otherwise. It is defined by name in `tools/aseprite/lib/pixel.lua`, so keep the two in sync.
- Palette: Herbs n Spices Palette (
#593a31,
#39202e
#613140
#83443e
#c98d3f
#dac282
#9a945c
#6b6657
#384150
#6e7e8d
#90b5c6
#f5efe8
#ab99a4
#55516f
#463554
#17111a)
