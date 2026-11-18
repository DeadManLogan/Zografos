# Reference analysis (Claude's read)

Companion to `references_notes.md` (the user's own words). Written after viewing each file once,
so later sessions can work from this text instead of re-opening the images.
Status per file: `analysed` = already viewed; only re-open for a specific comparison.

## romain-courtois-x-x.jpg (cafe): analysed, LIKED
- Scene illustration, fairly high resolution (objects are many pixels tall).
- **No black outlines anywhere.** Forms read through flat value masses and colour.
- Characters: realistic proportions (small heads, long legs), 2–3 values per material, readable by silhouette alone.
- Foliage: big flat clusters with 2–3 values each, little texture noise. Simple, and it reads as plants.
- Architecture: observed from life (corrugated roof, boards, worn paint, a hand-painted sign). Wear is shown with a few deliberate marks, not noise.
- Light: warm and soft. Pale cyan sky. Background jungle is lower in contrast than the building, so there is a focal hierarchy.

## romain-courtois-x-reso-x4.jpg (gas station): analysed, DISLIKED ("too crispy, hard on the eye")
My diagnosis of the "can't explain it":
- **No atmospheric perspective.** The palm and cypresses in the background are as dark, saturated and hard-edged as the foreground, so everything competes and depth flattens. The cafe image softens its background; this one doesn't.
- **High global contrast:** a saturated deep-blue sky behind near-white walls, plus a huge hard diagonal shadow with a big value jump.
- **Busy micro-detail everywhere** (grates, rust specks, cables) at the same contrast, with no quiet areas for the eye to rest.
- Takeaway: what the user dislikes is **uniform contrast**, not this artist. Contrast should be spent on the focal point.

## philipp-a-urlich-tree-scene-serene-1.jpg: analysed, LIKED
- Natural, lively palette. Greens hue-shift warm and yellow in the light, and blue-purple in the shade. Moderate saturation.
- Foliage drawn as clumps shaded by depth (lit outer clumps, dark core), exactly the method in our lighting guide.
- **Value hierarchy:** the hero tree has the strongest contrast and saturation. Distant trees go bluer, lighter and flatter. This is the same principle the user missed in the gas station.
- More painterly texture (broken edges and speckle in the sky, grass and flowers) than Courtois, but still clustered, not random.
- No outlines.

## sea_birds.png: analysed. Birds LIKED, background DISLIKED
- Native size ~192×108 (shown at 5×). Low resolution, yet the birds feel alive.
- Birds: realistic anatomy, dynamic gesture. Feathers are suggested with directional strokes (pixel clusters following the feather direction). No outline. Strong white/near-black contrast on the birds only.
- Background: murky olive/teal/grey with a narrow value range. It does make the birds pop (the signal-vs-noise rule), so the problem is probably the **hue** (muddy greenish) rather than the low contrast. Ask the user to confirm.

## mendacious_visage.png: analysed. LIKED for the concept
- Native 140×140 (shown at 16×). The user likes the **creature design** (a hybrid of several entities), not necessarily the rendering. File under subject/design, not rendering.
- Rendering: near-monochrome (blue-grey and bone), big flat value shapes, no outline, design carried by silhouette.

## panda.gif: analysed. LIKED for the animation and the process
- 21 frames, alternating 50/100 ms. Each frame shows a **rough block-out** (body parts as flat colour-coded shapes) next to the **final**.
- Matches the block-out-first rule already in the pixel-art skill. The user values seeing process and anatomy.
- Final: cream body, black limbs, thin dark contour, minimal shading.

## Patterns so far (candidates for style.md, not decided)
1. **Grounded realism:** realistic proportions and things observed from life, not chibi or cartoon. (cafe, birds, tree)
2. **No hard black outlines.** Form comes from value and colour masses. (all except the panda)
3. **Value hierarchy / focal contrast:** the subject gets the contrast, everything else recedes. The disliked image breaks this. (tree, cafe vs gas station)
4. **Natural, hue-shifted palette** with moderate saturation. No saturated pure sky blues. (tree, cafe vs gas station)
5. **Simplified clusters over noise** for foliage and surfaces. Detail shown once and implied elsewhere. (cafe, tree)
6. Mostly **illustration-scale** references. We still need in-game references (tiles, sprites at play size) to see how the style survives game constraints.

## Decisions so far (from experiments, user-approved)
- **2026-11-17, outline: keep it.** Compared `oil_lamp` (outlined) against `oil_lamp_no_outline` on SKAVO's backgrounds. The user prefers the outline for the game, even though the illustration refs don't use one. Use the *selective* outline from the first lamp: dark red (c06) on lit edges, purple-dark (c11) on the sides, blue-black (c14) on shadow edges, so the outline only looks black along the bottom half.
- **2026-11-17, shade count: many shades.** Keep the 5–6-step material ramps of `oil_lamp`, not 3-value flat clusters.

## Open questions for the user
- Sea birds background: is the problem the murky colour, or the low contrast?
- Any in-game screenshots (not illustrations) in this direction?
