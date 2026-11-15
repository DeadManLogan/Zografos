# Colour & ramps (fixed palette)

Source: Adam C. Younis, "Palettes & Colours" (transcript in `.claude/youtube_transcribs/adamcyounis/pixel_art_class/`).
The video is about *building* a palette. Here each sprite uses one fixed palette from `palettes/`, so the rules below are adapted to *choosing ramps from it*. Read this when picking ramps (workflow step 1).

The principles apply to every palette. The brightness table and ramp table below are for the default palette, **Herbs n Spices** (`palettes/herbs_n_spices.gpl`). When a sprite uses another palette for the first time, add the same two tables for it in a new section here (luma = 0.299 R + 0.587 G + 0.114 B, scaled to 0–100).

## Principles from the video
- **A palette can't cover the whole spectrum.** Every choice is about expressing what you need without adding colours. Never add a colour. Work within the 16.
- **Saturation is a tool, not a goal.** Don't pick the "bluest blue" for sky or the "greenest green" for grass. That reads juvenile. Colour reads from context: a greyish blue next to warm colours reads as a clear blue sky.
- **Get past intuition** ("grass = green, metal = grey, fire = red"). Pick by what the light is doing, not by the object's "real" colour.
- **Hue-shift every ramp: toward yellow/warm as it brightens, toward blue/purple/cool as it darkens.** This is the "filter" Adam uses in nearly every palette (brighter = warmer, darker = colder), and it feels natural.
- **Saturation peaks in the middle of a ramp** (the middle/upper third). The extremes are desaturated, so bright ends and dark ends blend into each other and across ramps.
- **Bridge colours** belong to several ramps at once. At the dark end everything converges on near-black, and at the bright end on near-white. Shared ends tie the whole sprite together.
- **Ramps don't have to stay in one hue family.** Dark yellow doesn't have to go green. It can go through brown or red toward cool (yellow → ochre → brown → plum). Choose what serves the content (Adam routed yellow through browns for wood, dirt and leather).
- **Check value steps by eye.** Neighbouring shades in a ramp should differ by a similar, visible amount. If two shades are nearly identical, use only one. If two neighbours are far apart, that seam becomes a hard edge (see `lighting-shading.md`).
- **Two colours with the same job is waste.** Each colour in a sprite should have a distinct role.

## Herbs n Spices by brightness
Luma = perceived brightness (0–100), computed from the hex values.

| name | hex | hue | sat | luma | role |
|---|---|---|---|---|---|
| bone | #f5efe8 | 32 | 5% | 94 | universal top bridge (white, warm) |
| sand | #dac282 | 44 | 40% | 76 | warm highlight for most ramps |
| sky | #90b5c6 | 199 | 27% | 67 | cool light, water, metal |
| mauve | #ab99a4 | 323 | 11% | 63 | neutral/pinkish light |
| ochre | #c98d3f | 34 | **69%** | 59 | most saturated colour: accents and focal points |
| olive | #9a945c | 54 | 40% | 56 | foliage base |
| slate | #6e7e8d | 209 | 22% | 48 | stone/metal base |
| moss_grey | #6b6657 | 45 | 19% | 40 | muted mid, foliage shade |
| terracotta | #83443e | 5 | 53% | 34 | warm mid-dark |
| dusk | #55516f | 248 | 27% | 34 | cool mid-dark, shadow tint |
| umber | #593a31 | 14 | 45% | 26 | warm dark |
| wine | #613140 | 341 | 49% | 26 | red/cloth dark |
| slate_dark | #384150 | 218 | 30% | 25 | cool dark |
| aubergine | #463554 | 273 | 37% | 24 | purple dark, sheen on black |
| plum_dark | #39202e | 326 | 44% | 16 | outline, universal dark bridge |
| ink | #17111a | 280 | 35% | 8 | near-black, glaze, deepest core |

What this means:
- The palette is **mid/low saturation** overall, which fits the "pick one saturation band and stay in it" advice. `ochre` is the only strongly saturated colour, so use it where the eye should go first, and don't spread it everywhere.
- **Dark end bridges:** `plum_dark`, `ink`, `aubergine` (all cool purple). End warm ramps in these instead of in a warmer brown, and you get the hue-shift for free.
- **Bright end bridges:** `bone` (whole palette) and `sand` (warm ramps). A cool ramp topping out in `bone` gets a slight warm shift, which is correct.
- **Almost the same brightness:** `umber` / `wine` / `slate_dark` / `aubergine` (24–26) and `terracotta` / `dusk` (34). Next to each other they separate by **hue only**, with no value contrast. That's good for subtle shifts (warm/cool shadow variation) and bad for form edges or readability at 1:1.

## Hue-shifted ramps (bright → dark)
Use these unless a sprite needs something specific. Each one goes warm at the top and cool at the bottom.

| Material | spec / top | highlight | base | shade | deep |
|---|---|---|---|---|---|
| Terracotta / clay | bone | sand | ochre | terracotta | umber → plum_dark |
| Wood / leather / dirt | sand | ochre | terracotta | umber | plum_dark |
| Foliage | sand | olive | moss_grey | slate_dark | ink |
| Stone / metal | bone | sky | slate | slate_dark | ink |
| Cloth (wine) | mauve | – | wine | plum_dark | ink |
| Water / cold sky | bone | sky | slate | dusk | aubergine |
| Neutral / shadow tint | bone | mauve | dusk | aubergine | ink |
| Black glaze | aubergine (sheen) | – | ink | – | – |

Pick **3–5 ramps per sprite**. Shared bridges (`plum_dark`, `ink`, `bone`, `sand`) don't count against that budget.

## Checklist
- [ ] Every ramp shifts warm going up and cool going down.
- [ ] Saturated colours (`ochre`, `terracotta`, `wine`) sit in the mid-tones and focal areas, not at the extremes.
- [ ] Neighbouring shades used for *form* differ clearly in luma (≥ ~8). Equal-luma pairs are used only on purpose.
- [ ] No two colours doing the same job.
- [ ] Sky/grass/metal colours chosen for the lighting, not as "the colour of the thing".
