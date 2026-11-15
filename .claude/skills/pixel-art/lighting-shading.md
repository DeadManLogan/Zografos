# Lighting & shading

Source: Adam C. Younis, "Lighting & Shading Basics" and the tree demo in "How To Use References Effectively" (transcripts in `.claude/youtube_transcribs/adamcyounis/pixel_art_class/`).
Read this when planning (workflow step 1) and when reviewing (step 5).

## How light decides value
- The more directly a surface faces the light, the brighter it is. A face parallel to the light rays (normal at 90° to the light) gets no light and goes dark.
- On a round form the brightness falls off **gradually** as the surface turns away. The bottom, facing away from the light, gets none.
- Light comes from **above**. Things are almost never lit from below unless there's a campfire or other low source. This project uses **top-left** (see SKILL.md). Adam prefers straight top lighting. Either works. What matters is that **one direction is used across the whole sprite and every frame of a sheet**.

## Distribute shades on a bell curve, not evenly
With only 3–5 shades per ramp, *how many pixels* each shade gets matters more than where the bands sit.
- Treat the pixel count per shade as a **bell curve**. The **base colour takes most of the area**. Neighbouring shades get less. The darkest and brightest shades get very little.
- Rough starting targets (my numbers; the video gives the idea, not figures): base ≈ 50–60%, shade ≈ 20–25%, highlight ≈ 10–15%, deep shade ≈ 5%, specular/brightest ≤ 3%. Outline pixels are not counted.
- Adam's gear example: brightest shade ≈ 15 px, next a bit more, the body colour "a lot", then less again at top and bottom.
- Band spacing is **non-linear**. Don't space the bands evenly from light to dark.
- **Banding is acceptable if it's consistent.** One rule applied everywhere beats many local fixes.

**Review check:** count the pixels per colour in the 16× preview. If the highlight or the deep shade covers as much area as the base, the form looks flat or muddy, so pull it back.

## Edges are controlled by contrast
- **Hard edge** (cube corner, blade edge, plank edge): put two faces next to each other with a **big value jump**, skipping a ramp step (e.g. `sand` face next to `terracotta` face, with no `ochre` between).
- **Rounded/soft edge**: add the in-between shade along the seam. It softens the transition **and makes the edge look bevelled**. Only do this when you want it rounded.
- **Specular highlight**: one or a few pixels of the brightest colour on the corner or edge that faces the light. It adds drama and makes the edge read **sharper**. Use it on metal, glaze, wet or polished surfaces, and sparingly.
- **Rim light**: a thin line of light on the edge facing *away* from the main light, as if light is leaking around the back. Use it to separate a dark object from a dark background. Keep it one pixel wide and partial, not a full outline.

## Complex forms: shade by depth, not by side
Clusters (foliage, hair, fur, cloth folds, crowds of small parts) are many objects stacked on each other, not one ball. So:
- Don't just darken "the bottom-right". **Dark = deep inside / occluded. Light = outer and closer to the light.** The core of a tree is dark because you're looking through leaves into shadowed branches.
- Treat each clump as its own small object (oval clumps for leaves). Give each one the same lighting rule: lit top, darker underside.
- **Upper clumps cast shadow on the clumps below.** The base of a clump just above a lit clump goes dark.
- Work **dark shapes first, then lighter shapes on top**, then a very sparing brightest shade for the bits catching direct sun.
- Most light at the top of the form, becoming "very, very sparing" towards the bottom.
- High contrast (very bright clump against very dark gap) reads best where the form rolls toward the viewer, e.g. the middle and lower bases of clumps.

## Branches, trunks and other linear parts
- The part exposed to light (top surface of a branch) is lighter. Parts deeper in the structure are darker. Where branches overlap, the one behind gets shadow.
- Add one extra-bright shade **only on select top edges** where light hits straight down.
- Surface texture (bark rips, wood grain, cracks) runs **along the form**. Add it after the light and shadow are working, never before.

## Checklist (put in the written critique)
- [ ] Single light direction, consistent across all parts and frames.
- [ ] Pixel count per shade follows a bell curve, with the base colour dominant.
- [ ] Hard edges use a skipped step and soft edges use the in-between. Nothing is accidentally bevelled.
- [ ] Specular/rim used deliberately and sparingly, or not at all.
- [ ] Clustered forms shaded by depth/occlusion, not by left/right side.
- [ ] No pillow shading (see SKILL.md).
