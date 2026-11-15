# Readability, contrast & style consistency

Source: Adam C. Younis, "Art Styles for Indie Games" and "Top Down Style Analysis & Tutorial" (transcripts in `.claude/youtube_transcribs/adamcyounis/pixel_art_class/`).
Read this in workflow step 1 to decide **how much each sprite should grab the eye**, and in step 5 to check it. It matters most for characters, pickups, tiles and anything that sits in a scene.

## Signal vs. noise
- Every sprite is either **signal** (player, NPCs, enemies, pickups, interactables: must be seen at a glance) or **noise/ground** (walkable terrain, backdrops, decoration: the eye should slide over it).
- How eye-catching something is depends on **contrast**, not on how much detail it has. Terrain can be richly detailed and still quiet if the distance between its darkest and brightest colour is small.
- **What grabs the eye:** high value contrast, **closed shapes** (an outlined shape completely enclosed), clusters of closed shapes, saturated colour, dense detail.
- **What stays quiet:** low value range, open/unoutlined shapes, desaturated colour, sparse detail.
- Decide the role in the plan: write `role: signal` or `role: ground` next to the canvas size.

### Signal sprites (characters, items, interactables)
- Use the **full value range** of the chosen ramps, with a dark outline (`plum_dark`). Outlines create closed shapes, which is exactly what draws the eye.
- Give them the **most saturated colours** in the scene (`ochre`, `terracotta`, `wine`, `sky`). This is "selective colour": a muted world with bright, saturated actors.
- **Silhouette test:** filled in solid black, every character must still be identifiable and distinct from the others. Get there through **exaggeration/caricature** of the defining feature (helmet, horns, hat, weapon), not anatomical accuracy.
- An important pickup can be the **brightest thing on screen**.

### Ground sprites (terrain tiles, floors, backdrops)
- **Low contrast:** keep the whole tile inside a narrow luma band (≈ 10–15 luma between darkest and lightest; see the table in `color-ramps.md`).
- **Detail without contrast:** vary only *one* channel slightly at a time: a slightly different **hue**, **saturation** *or* **brightness**. Our palette has no near-duplicates, so use the **equal-luma groups** from `color-ramps.md` (`umber`/`wine`/`slate_dark`/`aubergine` at 24–26, and `terracotta`/`dusk` at 34). Next to each other they give texture with almost no value contrast.
- No outlines on walkable ground. Keep the centre open and put detail **at the edges** of patches.
- Repeat a small detail motif (grass tuft, crack) sparingly. Seen once, the eye assumes it everywhere.

### Non-walkable / out-of-bounds areas (dense forest, cliffs, walls)
- These can be **noisy and high contrast**. The contrast difference between them and the soft walkable ground is what tells the player "you can't go there".
- **Contrast gradient:** put the highest contrast and noise **at the boundary** with walkable ground (light-meets-shadow edge), then fade contrast and brightness down going deeper into the blocked area. Darker, noisier areas feel like "visual gravity" pulling the player back to the light, open paths.
- **Back layers flatter:** for rows of trees or other repeated depth layers, remove the highlights from the rear rows so the front row stands out.
- Solids (buildings, rocks) use sharp, rigid colour changes. Walkable ground uses smooth, close colours.

## Top-down specifics
- In top-down, light usually comes from roughly where the viewer is, so **light/shadow alone can't separate walkable from blocked**. Use contrast and noise level instead (above).
- **Cast shadows ground objects.** Without one, a tree or building floats. Use a darker shade of the ground colour, broken up by the ground texture at its edges.
- **Doorways and entrances are very dark** (deep shadow, `ink`/`plum_dark`), so they read instantly as "enter here".
- **Layered foliage texture (fronds):** draw one leaf-cluster "flick" shape and repeat it in layers. Each layer down uses the same shape one ramp step darker, with its highlight one step above its own body colour. Shade the tops of tree canopies more than the bottoms.
- Avoid sky/horizon in a top-down view. It rarely works.

## Style = consistent decisions
- Style is **consistency of decisions**, palette or no palette. The same situation must always get the same treatment.
- Check two things across a sprite set or scene:
  - **Brightness modulation:** two similar vertical surfaces (a wall and a cliff) under the same sun must darken toward their base in the same way.
  - **Tone/temperature:** the same material in the same light must hue-shift the same direction. Don't let dirt go warm orange in one spot and cool green-brown in another.
- Pick a style "box" and stay inside it. With a fixed 16-colour palette and small sprites, this project is a **limited/retro-leaning** style. The challenge there is readable, distinct forms and artful palette use. Don't chase painterly high-detail rendering on 16×16 sprites; it turns to noise.
- **Selective outline ("sel-out")** is the higher-fidelity alternative to a flat black outline: tint the outline with the neighbouring colours, lighter on the lit side. Use it on larger sprites (32 px+) where a hard outline looks heavy. Keep the full dark outline on small signal sprites.

## Checklist
- [ ] Plan states `role: signal` or `role: ground`.
- [ ] Signal: full value range, outline, saturated colours, passes the black-silhouette test and is distinct from sibling sprites.
- [ ] Ground: narrow luma band, detail through hue/saturation shifts, no outline, open centre.
- [ ] Blocked areas: contrast peaks at the walkable edge and fades inward. Back layers flatter.
- [ ] Same material and light get the same brightness and temperature treatment across the whole set.
