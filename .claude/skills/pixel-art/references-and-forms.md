# References, transformation & building forms

Source: Adam C. Younis, "How To Use References Effectively" (transcript in `.claude/youtube_transcribs/adamcyounis/pixel_art_class/`).
Read this in workflow step 1 (planning) for any new sprite, and in step 5 (review).

## Using references (planning)
- **Reference attributes, not one image.** Before drawing, list 3–5 real-world sources or art styles and say exactly what you're taking from each: "silhouette from X, colour mood from Y, lighting from Z, technique from W". Collecting several stops you from copying one image too closely.
- Pick references that have the **attributes you want**, not ones that already show the finished sprite.
- **Originality comes from transformation.** Change at least one aspect: proportion (stretch/exaggerate), angle, number of parts, merging two sources, or applying a technique from another medium (e.g. watercolour → pixel art). If you can't name a transformation, it's a copy.
- Never reproduce a specific existing game's sprites or characters. Reference real objects, historical artefacts and general styles instead.
- Write the reference list and the chosen transformation into the plan (step 1) so the critique can check it.

## Building a form: big → medium → small
The structure has to read at every level: overall **silhouette**, then **major masses/clumps**, then **small details inside**.
1. **Silhouette:** block in with one flat colour. Check gesture and balance first (lean, taper, overall shape).
2. **Skeleton/structure** (for organic things like trees, creatures, plants): lay down the core lines first, e.g. a tree's branch system before any leaves.
   - **Taper:** limbs get thinner as they fork. A part that is too thick too far out (or thins "too late") looks wonky.
   - Prefer gentle crookedness and leaning over a single straight trunk. Keep a **flowing line** the eye can follow from base to tip.
3. **Masses:** add the big clumps with a **big brush**, i.e. large simple shapes. They must not completely hide the structure: let some branches or limbs show through.
4. **Break up the edges:** cut into the masses to suggest smaller units (leaves, feathers, fur tufts). **Show a detail once or twice and the eye assumes it everywhere.** Don't render every leaf.
5. **Small shapes stay on the edges of big shapes.** Add little shapes at the boundaries between colours or masses. Don't put small shapes that cut across the middle of a big shape, because that destroys the big shape.
6. Use a consistent "brush" shape for the small marks (e.g. small soft ovals for leaves) so it looks like one deliberate technique.

## Shapes of shapes
Look at the *shape of each shadow and highlight cluster*, not only the colour. Smooth wonky clusters. For leaves, aim for ovals. Every cluster should help describe the form.

## Rules beat randomness
"If you have a rule you're following, the rule will appear to flow naturally across the image. Without one it looks random." Before shading, decide the rule (light direction, what's deep vs. outer, clump shape, texture direction) and apply it everywhere, in every frame of a sheet.

## Clean-up and checks
- **Step back and compare against the plan and references.** Ask "what have I lost along the way?" and restore the defining features (e.g. the 4 major branch masses).
- **Remove orphan pixels.** A single pixel not contributing to a shape is distracting. Deliberate breakup is fine; noise isn't.
- **Test on light AND dark backgrounds** (the preview checkerboard is mid-tone). If the sprite disappears on either, fix the edge contrast with outline colour or a rim light (see `lighting-shading.md`).
- **Let the background in.** Negative space inside the silhouette (gaps between clumps or limbs) gives shape back. Erase to open it up if it got clogged.

## Coloured / selective outlines (optional)
Adam doesn't usually outline, but a coloured outline worked well on the tree: a **dark brown or dark green** instead of black.
- **Selective outline:** brighten the outline where the object is lit and darken it where it's in shadow. This looks more polished.
- In this project, `plum_dark` is the default outline. For organic sprites, consider `umber` (wood/earth) or `slate_dark` (foliage) as the outline, lightened on the lit side (e.g. `moss_grey` or `terracotta`).
- After adding an outline, check again for orphan pixels poking through it.

## Ground / grass (top-down or side)
- Ground under an object takes a **broken cast shadow** from it, kept minimal so it doesn't overpower the piece.
- **Raised grass patches:** outline a section and give it its own shading, as if it sits on its own height layer.
- Small slightly-darker shapes inside an outlined patch read as grass blades. Finish with a few sparse highlight pixels for "shimmer".

## Checklist
- [ ] Plan lists references with the attribute taken from each, plus the transformation.
- [ ] Silhouette → structure → masses → small detail, each readable.
- [ ] Taper and flow on organic forms.
- [ ] Small shapes on the edges of masses, not cutting through them.
- [ ] No orphan pixels. Readable on light and dark backgrounds.
